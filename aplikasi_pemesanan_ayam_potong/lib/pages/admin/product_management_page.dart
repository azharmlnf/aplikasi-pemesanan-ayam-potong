// lib/pages/admin/product_management_page.dart

import 'package:app_pemesanan_ayam_potong/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/database_service.dart';
import '../common/product_detail_page.dart';
import 'create_product_page.dart';
import 'edit_product_page.dart';
import '../../services/auth_service.dart'; // <-- 1. IMPORT AuthService

// --- WIDGET UNTUK KARTU PRODUK (TIDAK ADA PERUBAHAN) ---
class ProductCard extends StatelessWidget {
  final models.Document product;
  final DatabaseService databaseService;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.product,
    required this.databaseService,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productData = product.data;
    final name = productData['name'] ?? 'Tanpa Nama';
    final price = productData['price'] ?? 0.0;
    
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FutureBuilder<List<models.Document>>(
                future: databaseService.getProductImages(product.$id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return Image.network(
                      snapshot.data!.first.data['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    );
                  }
                  return Container(color: Colors.grey.shade200, child: const Icon(Icons.inventory_2, size: 40, color: Colors.grey));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('Rp ${price.toStringAsFixed(0)}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(icon: Icon(Icons.edit, color: Colors.blue.shade700, size: 20), onPressed: onEdit, tooltip: 'Edit'),
                  IconButton(icon: Icon(Icons.delete, color: Colors.red.shade700, size: 20), onPressed: onDelete, tooltip: 'Hapus'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN UTAMA MANAJEMEN PRODUK ---
class ProductManagementPage extends StatefulWidget {
  final DatabaseService databaseService;
  final AuthService authService; // <-- 2. TAMBAHKAN AuthService
  const ProductManagementPage({
    Key? key, 
    required this.databaseService, 
    required String userRole, 
required this.authService, // <-- 3. JADIKAN WAJIB DI CONSTRUCTOR    
}) : super(key: key);

  @override
  _ProductManagementPageState createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  late Future<List<models.Document>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = widget.databaseService.getProducts();
    });
  }

  // --- FUNGSI NAVIGASI YANG SUDAH DIPERBAIKI ---

  // Navigasi saat tombol '+' ditekan
  void _navigateToAddPage() async {
    final result = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => CreateProductPage(databaseService: widget.databaseService)),
    );
    if (result == true && mounted) _refreshProducts();
  }

  // Navigasi saat tombol 'edit' di kartu ditekan
  void _navigateToEditPage(models.Document product) async {
    final result = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => EditProductPage(databaseService: widget.databaseService, product: product)),
    );
    if (result == true && mounted) _refreshProducts();
  }

  // Navigasi saat kartu produk ditekan
  void _navigateToDetailPage(models.Document product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          databaseService: widget.databaseService,
          product: product,
          userRole: 'admin', // Kirim peran 'admin'
         // --- 4. PERBAIKI BAGIAN INI ---
          // Gunakan authService dari widget, bukan Provider.of
          authService: widget.authService,         ),
      ),
    );
    // Jika halaman detail kembali dengan 'true' (karena ada editan dari sana), refresh juga
    if (result == true && mounted) _refreshProducts();
  }

  // Aksi saat tombol 'delete' di kartu ditekan
  void _deleteProduct(models.Document product) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus produk "${product.data['name'] ?? 'ini'}"?'),
        actions: [
          TextButton(child: const Text('Batal'), onPressed: () => Navigator.of(context).pop(false)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      try {
        await widget.databaseService.deleteProduct(product.$id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus!'), backgroundColor: Colors.green));
        _refreshProducts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator( // Tambahkan RefreshIndicator agar bisa refresh dengan pull-to-refresh
        onRefresh: () async => _refreshProducts(),
        child: FutureBuilder<List<models.Document>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Belum ada produk. Ketuk + untuk menambah.'));
            }
      
            final products = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  databaseService: widget.databaseService,
                  onTap: () => _navigateToDetailPage(product),
                  onEdit: () => _navigateToEditPage(product),
                  onDelete: () => _deleteProduct(product),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPage,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Produk',
      ),
    );
  }
}