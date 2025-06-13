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

  Future<void> deleteProduct(String documentId, String imageUrl) async {
    final fileId = Uri.parse(imageUrl).pathSegments.last;
    await storage.deleteFile(
        bucketId: AppwriteConstants.productsBucketId, fileId: fileId); // DIGANTI
    await databases.deleteDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId, // DIGANTI
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

