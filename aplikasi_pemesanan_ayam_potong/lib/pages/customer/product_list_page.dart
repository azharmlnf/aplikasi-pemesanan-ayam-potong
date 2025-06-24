// lib/pages/customer/product_list_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../providers/cart_provider.dart';
import '../common/product_detail_page.dart';

class CustomerProductListPage extends StatefulWidget {
  final DatabaseService databaseService;
  final AuthService authService;
  final String userRole;
  // Callback untuk navigasi terpusat
  final VoidCallback onNavigateToCart; 

  const CustomerProductListPage({
    Key? key,
    required this.databaseService,
    required this.authService,
    required this.userRole,
    required this.onNavigateToCart,
  }) : super(key: key);

  @override
  State<CustomerProductListPage> createState() => _CustomerProductListPageState();
}

class _CustomerProductListPageState extends State<CustomerProductListPage> {
  late Future<List<models.Document>> _productsFuture;
  late CartProvider _cartProvider; // Variabel untuk menyimpan provider

  @override
  void initState() {
    super.initState();
    // Ambil instance CartProvider sekali saja
    _cartProvider = Provider.of<CartProvider>(context, listen: false);
    // Daftarkan listener untuk mendengarkan sinyal refresh
    _cartProvider.addListener(_checkAndPerformRefresh);
    // Muat produk pertama kali
    _refreshProducts();
  }

  @override
  void dispose() {
    // Selalu hapus listener saat widget dihancurkan untuk mencegah memory leak
    _cartProvider.removeListener(_checkAndPerformRefresh);
    super.dispose();
  }

  // Fungsi untuk memuat ulang data produk
  void _refreshProducts() {
    if (mounted) {
      setState(() {
        _productsFuture = widget.databaseService.getProducts();
      });
    }
  }

  // Fungsi yang akan dipicu oleh provider saat ada sinyal refresh
  void _checkAndPerformRefresh() {
    if (_cartProvider.requiresProductRefresh) {
      print("Sinyal refresh stok diterima, memuat ulang daftar produk...");
      _refreshProducts();
      // Reset sinyalnya agar tidak me-refresh terus-menerus
      _cartProvider.setRequiresRefresh(false);
    }
  }

  // Fungsi untuk navigasi ke halaman detail
  void _navigateToDetailPage(models.Document product) async {
    // Kita tidak perlu menunggu hasil (await) di sini lagi karena
    // listener akan menangani refresh secara otomatis saat kita kembali.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          databaseService: widget.databaseService,
          product: product,
          userRole: widget.userRole,
          authService: widget.authService,
          // Teruskan callback navigasi keranjang
          onNavigateToCart: widget.onNavigateToCart, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
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
              return const Center(child: Text('Saat ini belum ada produk tersedia.'));
            }

            final products = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCatalogCard(
                  product: product,
                  databaseService: widget.databaseService,
                  onTap: () => _navigateToDetailPage(product),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
// Widget terpisah untuk kartu produk di katalog customer
class _ProductCatalogCard extends StatelessWidget {
  final models.Document product;
  final DatabaseService databaseService;
  final VoidCallback onTap;

  const _ProductCatalogCard({
    Key? key,
    required this.product,
    required this.databaseService,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productData = product.data;
    final name = productData['name'] ?? 'Tanpa Nama';
    final price = productData['price'] ?? 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Area Gambar
            Expanded(
              child: FutureBuilder<List<models.Document>>(
                future: databaseService.getProductImages(product.$id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData &&
                      snapshot.data!.isNotEmpty) {
                    return Image.network(
                      snapshot.data!.first.data['imageUrl'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    );
                  }
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.inventory_2, size: 40, color: Colors.grey)),
                  );
                },
              ),
            ),
            // Area Teks Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${price.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}