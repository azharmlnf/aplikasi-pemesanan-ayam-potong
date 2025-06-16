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

  // Fungsi private untuk upload satu gambar dan mengembalikan ID & URL-nya
  Future<Map<String, String>> _uploadImage(File imageFile) async {
    try {
      // 1. Upload file seperti biasa
      final file = await storage.createFile(
        bucketId: AppwriteConstants.productsBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: imageFile.path, filename: imageFile.path.split('/').last),
      );

      // 2. Bangun URL secara manual menggunakan template yang benar
      final imageUrl = 
        '${AppwriteConstants.endpoint}/storage/buckets/${AppwriteConstants.productsBucketId}/files/${file.$id}/view?project=${AppwriteConstants.projectId}';
      
      print('Generated Image URL: $imageUrl'); // Tambahkan print untuk debug

      // 3. Kembalikan file ID dan URL yang sudah benar
      return {'fileId': file.$id, 'imageUrl': imageUrl};
    } on AppwriteException catch (e) {
      print("Error saat upload gambar: ${e.message}");
      rethrow;
    }
  }
  // Fungsi untuk menambahkan satu gambar ke sebuah produk
  Future<void> addImageToProduct(String productId, File imageFile) async {
    final imageDetails = await _uploadImage(imageFile);

    await databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productImagesCollectionId,
      documentId: ID.unique(),
      data: {
        'productId': productId,
        'imageUrl': imageDetails['imageUrl'],
        'fileId': imageDetails['fileId'],
      },
      permissions: [Permission.read(Role.any())],
    );
  }
// FUNGSI BARU: Mendapatkan semua gambar untuk sebuah produk
  Future<List<models.Document>> getProductImages(String productId) async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.productImagesCollectionId,
        queries: [
          Query.equal('productId', productId),
        ],
      );
      return result.documents;
    } on AppwriteException catch (e) {
      print("Gagal mendapatkan gambar produk: ${e.message}");
      return [];
    }
  }

  // FUNGSI BARU: Menghapus satu gambar spesifik
  Future<void> deleteProductImage(String imageDocumentId, String fileId) async {
    try {
      // 1. Hapus file dari Storage
      await storage.deleteFile(
        bucketId: AppwriteConstants.productsBucketId,
        fileId: fileId,
      );
      // 2. Hapus dokumen dari collection product_images
      await databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.productImagesCollectionId,
        documentId: imageDocumentId,
      );
    } on AppwriteException catch (e) {
      print("Gagal menghapus gambar: ${e.message}");
      rethrow;
    }
  }

  // --- FUNGSI UTAMA UNTUK PRODUK (YANG MEMANGGIL FUNGSI DI ATAS) ---

  Future<List<models.Document>> getProducts() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId,
    );
    return result.documents;
  }

  Future<models.Document> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required List<File> imageFiles,
  }) async {
    // 1. Buat dokumen produk terlebih dahulu
    final productDoc = await databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId,
      documentId: ID.unique(),
      data: {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
      },
      permissions: [Permission.read(Role.any())],
    );

    // 2. Loop dan upload setiap gambar, hubungkan ke produk yang baru dibuat
    // SEKARANG INI TIDAK AKAN ERROR KARENA 'addImageToProduct' SUDAH DIDEFINISIKAN DI ATAS
    for (var imageFile in imageFiles) {
      await addImageToProduct(productDoc.$id, imageFile);
    }

    return productDoc;
  }

  // Fungsi untuk update produk
  Future<models.Document> updateProduct({
    required String documentId,
    required String name,
    required String description,
    required double price,
    required int stock,
  }) async {
    // Fungsi ini sekarang HANYA mengurus data produk, bukan gambar.
    // Tambah/hapus gambar akan ditangani oleh fungsi lain.
    return databases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId,
      documentId: documentId,
      data: {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
      },
    );
  }

   // Modifikasi fungsi deleteProduct untuk CASCADE DELETE
  Future<void> deleteProduct(String documentId) async {
    // 1. Dapatkan semua dokumen gambar yang terhubung dengan produk ini
    final imagesToDelete = await getProductImages(documentId);

    // 2. Loop dan hapus setiap gambar (file & dokumen)
    for (var imageDoc in imagesToDelete) {
      // Panggil fungsi deleteProductImage yang sudah kita buat
      await deleteProductImage(imageDoc.$id, imageDoc.data['fileId']);
    }

    // 3. Terakhir, setelah semua gambar terkait dihapus, hapus dokumen produk itu sendiri
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
