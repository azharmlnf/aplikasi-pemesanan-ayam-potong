import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models; // Penting untuk import models
import '../utils/appwrite_constants.dart';
import 'dart:io';

class DatabaseService {
  final Databases databases;
  final Storage storage; // Tambahkan Storage

  DatabaseService({
    required this.databases,
    required this.storage,
  }); // Update constructor

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
      file: InputFile.fromPath(
        path: imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    );
    return file.$id;
  }

  String getImageUrl(String fileId) {
    // Disederhanakan
    return storage
        .getFileView(
          bucketId: AppwriteConstants.productsBucketId, // DIGANTI
          fileId: fileId,
        )
        .toString();
  }

  // Fungsi CREATE yang diperbarui
  Future<models.Document> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
  }) async {
    // Tidak ada lagi logika gambar di sini
    return databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId,
      documentId: ID.unique(),
      data: {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
      },
      // Anda bisa tetap memberikan izin level dokumen jika mau
      permissions: [
        Permission.update(Role.team(AppwriteConstants.adminTeamId)),
        Permission.delete(Role.team(AppwriteConstants.adminTeamId)),
      ],
    );
  }

  // Fungsi untuk update produk
  Future<models.Document> updateProduct({
  required String documentId,
  required String name,
  required String description,
  required double price,
  required int stock,
}) async {
  // Tidak ada lagi logika gambar di sini
  final data = {
    'name': name,
    'description': description,
    'price': price,
    'stock': stock,
  };

  return databases.updateDocument(
    databaseId: AppwriteConstants.databaseId,
    collectionId: AppwriteConstants.productsCollectionId,
    documentId: documentId,
    data: data,
  );
}

  Future<void> deleteProduct(String documentId) async {
  // TODO: Hapus semua gambar terkait dari product_images dan Storage terlebih dahulu
  // Untuk sekarang, kita hanya hapus produknya
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
      queries: [Query.orderDesc('orderDate')],
    );
    return result.documents;
  }

  Future<models.Document> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    return databases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.ordersCollectionId, // DIGANTI
      documentId: orderId,
      data: {'status': newStatus},
    );
  }
}
