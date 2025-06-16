// lib/pages/admin/product_management_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/database_service.dart';
// Nantinya kita akan buat file ini
import 'create_product_page.dart'; // Import halaman create
import 'edit_product_page.dart'; // Import halaman edit
import '../common/product_detail_page.dart';
// WIDGET BARU UNTUK KARTU PRODUK
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
        clipBehavior: Clip.antiAlias, // Agar gambar di dalam Card mengikuti bentuk rounded
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Area Gambar
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
                  // Tampilkan ikon placeholder jika tidak ada gambar atau saat loading
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.inventory_2, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),
            
            // Area Info Produk
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${price.toStringAsFixed(0)}',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Area Tombol Aksi
            Container(
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue.shade700, size: 20),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red.shade700, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
class ProductManagementPage extends StatefulWidget {
  final DatabaseService databaseService;
  final String userRole; // <-- TAMBAHKAN INI
  const ProductManagementPage({
    Key? key,
    required this.databaseService,
    required this.userRole, // <-- TAMBAHKAN INI
  }) : super(key: key);

  @override
  _ProductManagementPageState createState() => _ProductManagementPageState();
}

// lib/pages/admin/product_management_page.dart

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

  void _navigateToAddPage() async {
    final result = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => CreateProductPage(databaseService: widget.databaseService)),
    );
    if (result == true) _refreshProducts();
  }

  void _navigateToEditPage(models.Document product) async {
    final result = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => EditProductPage(databaseService: widget.databaseService, product: product)),
    );
    if (result == true) _refreshProducts();
  }

void _navigateToDetailPage(models.Document product) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductDetailPage(
        databaseService: widget.databaseService,
        product: product,
        userRole: 'admin', // <-- KIRIM PERAN 'ADMIN' SECARA EKSPLISIT
      ),
    ),
  );
}
void _viewProductDetail(models.Document product) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductDetailPage(
        databaseService: widget.databaseService,
        product: product,
        userRole: 'customer', // <-- KIRIM PERAN 'CUSTOMER'
      ),
    ),
  );
}

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

    if (shouldDelete == true) {
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
      body: FutureBuilder<List<models.Document>>(
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
          // --- GUNAKAN GRIDVIEW.BUILDER DI SINI ---
          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 kolom
              crossAxisSpacing: 12.0, // Jarak horizontal antar kartu
              mainAxisSpacing: 12.0, // Jarak vertikal antar kartu
              childAspectRatio: 0.75, // Rasio lebar:tinggi kartu. Sesuaikan jika perlu
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPage,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Produk',
      ),
    );
  }
}