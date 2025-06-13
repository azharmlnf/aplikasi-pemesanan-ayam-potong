// lib/pages/admin/product_management_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/database_service.dart';
// Nantinya kita akan buat file ini
// import 'product_form_page.dart';

class ProductManagementPage extends StatefulWidget {
  final DatabaseService databaseService;
  const ProductManagementPage({Key? key, required this.databaseService}) : super(key: key);

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

  // Fungsi untuk navigasi ke form (akan dibuat nanti)
  // void _navigateAndRefresh(BuildContext context, {models.Document? product}) async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ProductFormPage(
  //         databaseService: widget.databaseService,
  //         product: product,
  //       ),
  //     ),
  //   );

  //   if (result == true) {
  //     _refreshProducts();
  //   }
  // }

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
            return const Center(child: Text('Belum ada produk.'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final productData = product.data; // Simpan data ke variabel agar lebih rapi

              // Ambil data dengan memberikan nilai default jika null
              final imageUrl = productData['imageUrl'] as String?; // Ambil sebagai String yg bisa null
              final name = productData['name'] as String? ?? 'Produk Tanpa Nama';
              final price = productData['price'] ?? 0.0;
              final stock = productData['stock'] ?? 0;

              return ListTile(
                leading: CircleAvatar(
                  // Cek jika imageUrl ada dan tidak kosong, jika tidak tampilkan ikon
                  backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                      ? NetworkImage(imageUrl)
                      : null,
                  child: (imageUrl == null || imageUrl.isEmpty)
                      ? const Icon(Icons.inventory_2)
                      : null,
                ),
                title: Text(name),
                subtitle: Text('Rp $price - Stok: $stock'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // Navigasi untuk edit
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (imageUrl != null) {
                           await widget.databaseService.deleteProduct(product.$id, imageUrl);
                           _refreshProducts();
                        } else {
                           // Handle jika imageUrl null tapi ingin menghapus
                           print("Tidak bisa menghapus karena imageUrl tidak ada");
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi untuk tambah
          // _navigateAndRefresh(context);
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Produk',
      ),
    );
  }
}