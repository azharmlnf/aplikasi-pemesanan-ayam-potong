import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models; // Penting untuk import models
import '../utils/appwrite_constants.dart';
import 'dart:io';
import '../models/cart_item.dart'; // <--- TAMBAHKAN IMPORT INI

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
  // Fungsi ini mengambil satu profil berdasarkan ID
  // Kita akan gunakan ini untuk mendapatkan nama customer
  Future<models.Document?> getProfile(String userId) async {
    try {
      return await databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.profilesCollectionId,
        documentId: userId,
      );
    } on AppwriteException catch (e) {
      if (e.code == 404) return null;
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
        file: InputFile.fromPath(
          path: imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
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
        queries: [Query.equal('productId', productId)],
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



  //memanggil semua products
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



  // ==============================
  // === FUNGSI CHECKOUT (DENGAN PENGURANGAN STOK) ===
  // ==============================
  Future<void> createOrderFromCart({
    required String userId,
    required List<CartItem> cartItems,
    required double totalPrice,
    String? description,
  }) async {
    // --- Langkah A: Validasi Stok Sebelum Membuat Pesanan ---
    for (var item in cartItems) {
      final productDoc = await getProductById(item.productId);
      final currentStock = productDoc.data['stock'] as int;
      if (currentStock < item.quantity) {
        // Jika stok tidak cukup, lempar error dan hentikan proses
        throw Exception('Stok untuk produk "${item.name}" tidak mencukupi. Sisa: $currentStock');
      }
    }

    // Jika semua stok aman, lanjutkan proses checkout...

    // 1. Buat DOKUMEN INDUK di collection 'orders'
    final orderDoc = await databases.createDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.ordersCollectionId,
      documentId: ID.unique(),
      data: {
        'customerId': userId,
        'totalPrice': totalPrice,
        'status': 'pending',
        'orderDate': DateTime.now().toIso8601String(),
        'description': description,
      },
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
        Permission.read(Role.users()),
        Permission.update(Role.users()),
      ],
    );

final orderId = orderDoc.$id;

    // 2. Loop, buat DOKUMEN DETAIL di 'order_items' DAN update stok
    for (var item in cartItems) {
      // Buat dokumen order_items
      await databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.orderItemsCollectionId,
        documentId: ID.unique(),
        data: {
          'orderId': orderId,
          'productId': item.productId,
          'quantity': item.quantity,
          'priceAtOrder': item.price,
          'pieces': item.pieces, // <-- PASTIKAN BARIS INI ADA
           'name': item.name, // <-- TAMBAHKAN BARIS INI UNTUK MENYIMPAN NAMA PRODUK
        },
        permissions: [
          Permission.read(Role.user(userId)),
          Permission.read(Role.users()),
        ],
      );
      // --- Langkah B: Kurangi Stok Produk ---
      try {
        // Ambil stok terbaru lagi untuk keamanan (jika ada pesanan lain masuk bersamaan)
        final productDoc = await getProductById(item.productId);
        final currentStock = productDoc.data['stock'] as int;
        final newStock = currentStock - item.quantity;
        
        // Update stok di database
        await _updateProductStock(item.productId, newStock);

      } catch (e) {
        // Jika gagal mengurangi stok, ini adalah masalah.
        // Kita bisa menambahkan logika kompensasi (misal: membatalkan pesanan yang baru dibuat)
        // atau cukup log error untuk diperiksa manual.
        print("PENTING: Gagal mengurangi stok untuk produk ${item.productId} pada pesanan $orderId. Error: $e");
      }
    }
  }
    

   // <<< FUNGSI BARU UNTUK MENGAMBIL DETAIL ITEM PESANAN >>>
  Future<List<models.Document>> getOrderItems(String orderId) async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.orderItemsCollectionId,
        queries: [
          Query.equal('orderId', orderId), // Filter item berdasarkan ID pesanan
        ],
      );
      return result.documents;
    } catch (e) {
      print("Gagal mendapatkan item pesanan: $e");
      return [];
    }
  }

  // FUNGSI UNTUK MENGUBAH STATUS PESANAN
  Future<models.Document> updateOrderStatus(String orderId, String newStatus) async {
    try {
      return await databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.ordersCollectionId,
        documentId: orderId,
        data: {
          'status': newStatus, // Hanya kirim data yang ingin diubah
        },
      );
    } catch (e) {
      print("Gagal mengubah status pesanan: $e");
      rethrow;
    }
  }
  // <<< FUNGSI BARU UNTUK AKSI MASSAL mengubah pesanan >>>
  Future<void> bulkUpdateOrderStatus(List<String> orderIds, String newStatus) async {
    // Appwrite tidak punya fitur update banyak dokumen sekaligus, jadi kita loop
    // Gunakan Future.wait untuk menjalankan semua permintaan secara paralel
    await Future.wait(
      orderIds.map((id) => updateOrderStatus(id, newStatus)),
    );
  }

  // === FUNGSI MANAJEMEN PESANAN ===

  // === FUNGSI MANAJEMEN PESANAN (DENGAN FILTER) ===

  // Fungsi untuk Admin (dengan filter status opsional)
  Future<List<models.Document>> getOrders({String? statusFilter}) async {
    try {
      // Buat list query dasar
      final List<String> queries = [
        Query.orderDesc('\$createdAt'),
      ];

      // Jika ada filter status, tambahkan ke query
      if (statusFilter != null && statusFilter.isNotEmpty) {
        queries.add(Query.equal('status', statusFilter));
      }

      final result = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.ordersCollectionId,
        queries: queries, // Gunakan list query yang sudah dibuat
      );
      return result.documents;
    } catch (e) {
      print("Gagal mendapatkan pesanan: $e");
      return [];
    }
  }

  // Fungsi untuk Customer (dengan filter status opsional)
  Future<List<models.Document>> getMyOrders(String userId, {String? statusFilter}) async {
    try {
      // Buat list query dasar
      final List<String> queries = [
        Query.equal('customerId', userId),
        Query.orderDesc('\$createdAt'),
      ];

      // Jika ada filter status, tambahkan ke query
      if (statusFilter != null && statusFilter.isNotEmpty) {
        queries.add(Query.equal('status', statusFilter));
      }
      
      final result = await databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.ordersCollectionId,
        queries: queries,
      );
      return result.documents;
    } catch (e) {
      print("Gagal mendapatkan riwayat pesanan: $e");
      return [];
    }
  }
  

  // === FUNGSI PEMBANTU UNTUK STOK (BARU) ===

  // Fungsi untuk mendapatkan satu dokumen produk berdasarkan ID
  Future<models.Document> getProductById(String productId) async {
    return databases.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId,
      documentId: productId,
    );
  }

// Fungsi untuk meng-update stok satu produk
Future<void> _updateProductStock(String productId, int newStock) async {
  // Tambahkan print statement untuk debugging
  print('Updating stock for product $productId to new value: $newStock');
  
  try {
    await databases.updateDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.productsCollectionId,
      documentId: productId,
      data: {
        'stock': newStock, // Pastikan key 'stock' sudah benar (huruf kecil semua)
      },
    );
    print('Stock for product $productId updated successfully.');
  } on AppwriteException catch (e) {
    // Jika ada error izin, ini akan tercetak di debug console
    print('AppwriteException while updating stock: ${e.message}');
  }
}

}
