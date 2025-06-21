// lib/pages/customer/product_list_page.dart

import 'package:app_pemesanan_ayam_potong/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/database_service.dart';
import '../common/product_detail_page.dart';

class CustomerProductListPage extends StatefulWidget {
  final DatabaseService databaseService;
   final AuthService authService; // <-- TAMBAHKAN INI
  final String userRole;

  const CustomerProductListPage({
    Key? key,
    required this.databaseService,
        required this.authService, // <-- TAMBAHKAN DI CONSTRUCTOR
    required this.userRole,
  }) : super(key: key);

  @override
  State<CustomerProductListPage> createState() => _CustomerProductListPageState();
}

class _CustomerProductListPageState extends State<CustomerProductListPage> {
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

  void _navigateToDetailPage(models.Document product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          databaseService: widget.databaseService,
          product: product,
          userRole: widget.userRole,
           authService: widget.authService, // <-- KIRIMKAN AUTHSERVICE DI SINI
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
                childAspectRatio: 0.8, // Sedikit lebih tinggi untuk tampilan katalog
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                // Menggunakan widget kartu produk yang dibuat di bawah
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