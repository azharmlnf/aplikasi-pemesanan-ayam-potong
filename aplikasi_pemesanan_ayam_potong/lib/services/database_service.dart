import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models; // Penting untuk import models
import '../utils/appwrite_constants.dart';
import 'dart:io';

class DatabaseService {
  final Databases databases;
  final Storage storage; // Tambahkan Storage

  DatabaseService({required this.databases, required this.storage}); // Update constructor


  Future<models.Document> createProfile({
    required String userId,
    required String username,
    required String name,
    required String phoneNumber,
  }) async {
    // KITA JUGA HARUS MENGEMBALIKAN NILAINYA DENGAN 'return'
    return await databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.profilesCollectionId,
      documentId: userId,
      data: {
        'username': username,
        'name': name,
        'phone_number': phoneNumber,
        'role': 'customer', // Default role saat registrasi
      },
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
      ],
    );
  }
  // Fungsi untuk mendapatkan role pengguna dari collection profiles
  Future<String?> getUserRole(String userId) async {
    try {
      final document = await databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.profilesCollectionId,
        documentId: userId,
      );
      return document.data['role'];
    } on AppwriteException catch (e) {
      print('Gagal mendapatkan role: ${e.message}');
      return null;
    }
  }
//menampilkan user yang login
 Future<models.Document?> getProfile(String userId) async {
    try {
      return await databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.profilesCollectionId,
        documentId: userId,
      );
    } on AppwriteException catch (e) {
      // Jika profil tidak ditemukan, kembalikan null
      if (e.code == 404) {
        return null;
      }
      print('Gagal mendapatkan profil: ${e.message}');
      rethrow;
    }
  }

//menampilkan product dari database
  Future<List<models.Document>> getProducts() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId, // DIGANTI
    );
    return result.documents;
  }

  Future<String> _uploadImage(File imageFile) async {
    final file = await storage.createFile(
      bucketId: AppwriteConstants.productsBucketId, // DIGANTI
      fileId: ID.unique(),
      file: InputFile.fromPath(path: imageFile.path, filename: imageFile.path.split('/').last),
    );
    return file.$id;
  }

  String getImageUrl(String fileId) { // Disederhanakan
    return storage.getFileView(
      bucketId: AppwriteConstants.productsBucketId, // DIGANTI
      fileId: fileId,
    ).toString();
  }

  Future<models.Document> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required File imageFile,
  }) async {
    final imageId = await _uploadImage(imageFile);
    final imageUrl = getImageUrl(imageId);

    return databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId, // DIGANTI
      documentId: ID.unique(),
      data: {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
      },
      permissions: [Permission.read(Role.any())],
    );
  }

// Fungsi untuk update produk
  Future<models.Document> updateProduct({
    required String documentId,
    required String name,
    required String description,
    required double price,
    required int stock,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      final imageId = await _uploadImage(imageFile);
      imageUrl = getImageUrl(imageId);
    }

    final data = {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
    };
// Hanya tambahkan imageUrl ke data jika ada gambar baru
    if (imageUrl != null) {
      data['imageUrl'] = imageUrl;
    }

    return databases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId, // DIGANTI
      documentId: documentId,
      data: data,
    );
  }

Future<void> deleteProduct(String documentId, String? imageUrl) async { // Ubah tipe menjadi String?
  // 1. Hapus gambar dari Storage HANYA JIKA imageUrl ada dan tidak kosong
  if (imageUrl != null && imageUrl.isNotEmpty) {
    try {
      // Ekstrak file ID dari URL
      final fileId = Uri.parse(imageUrl).pathSegments.last;
      await storage.deleteFile(
          bucketId: AppwriteConstants.productsBucketId, fileId: fileId);
    } catch (e) {
      // Abaikan error jika file tidak ditemukan di storage, mungkin sudah dihapus
      print("Gagal menghapus file dari storage (mungkin sudah tidak ada): $e");
    }
  }
  
  // 2. Selalu hapus dokumen dari Database
  await databases.deleteDocument(
    databaseId: AppwriteConstants.databaseId,
    collectionId: AppwriteConstants.productsCollectionId,
    documentId: documentId,
  );
}

  // === FUNGSI MANAJEMEN PESANAN ===
  
  Future<List<models.Document>> getOrders() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.ordersCollectionId, // DIGANTI
      queries: [
        Query.orderDesc('orderDate'),
      ],
    );
    return result.documents;
  }

  Future<models.Document> updateOrderStatus(String orderId, String newStatus) async {
    return databases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.ordersCollectionId, // DIGANTI
      documentId: orderId,
      data: {'status': newStatus},
    );
  }
}

