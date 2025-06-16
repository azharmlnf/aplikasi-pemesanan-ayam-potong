import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/database_service.dart';

class ProductDetailPage extends StatefulWidget {
  final models.Document product;
  final DatabaseService databaseService;
  final String userRole; // Parameter baru untuk mengetahui peran pengguna

  const ProductDetailPage({
    Key? key,
    required this.product,
    required this.databaseService,
    required this.userRole, // Jadikan wajib
  }) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<List<models.Document>> _imagesFuture;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _imagesFuture = widget.databaseService.getProductImages(widget.product.$id);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productData = widget.product.data;

    return Scaffold(
      appBar: AppBar(
        title: Text(productData['name'] ?? 'Detail Produk'),
        // Tampilkan tombol Edit HANYA jika pengguna adalah admin
        actions: widget.userRole == 'admin'
            ? [
                IconButton(
                  icon: const Icon(Icons.edit_note),
                  onPressed: () {
                    // TODO: Navigasi ke halaman edit
                    // Contoh: _navigateToEditPage(context, widget.product);
                  },
                  tooltip: 'Edit Produk',
                )
              ]
            : null,
      ),
      body: SingleChildScrollView(
        // ... (Isi dari Column tidak berubah, sama seperti sebelumnya)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData['name'] ?? 'Produk Tanpa Nama',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${productData['price']?.toStringAsFixed(0) ?? '0'}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Stok: ${productData['stock'] ?? 0}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Deskripsi Produk',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productData['description'] ?? 'Tidak ada deskripsi.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Tampilkan Tombol Aksi di Bawah berdasarkan Peran
      bottomNavigationBar: _buildBottomActionButton(),
    );
  }

  // Widget untuk tombol aksi di bagian bawah
  Widget? _buildBottomActionButton() {
    if (widget.userRole == 'customer') {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Tambah ke Keranjang'),
          onPressed: () {
            // TODO: Implementasi logika tambah ke keranjang
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur tambah keranjang belum diimplementasikan.')),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    // Jika bukan customer (misal: admin), tidak ada tombol di bawah
    return null;
  }

  // Widget untuk membangun galeri gambar
  Widget _buildImageGallery() {
    return FutureBuilder<List<models.Document>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: 250,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 60,
                color: Colors.grey,
              ),
            ),
          );
        }

        final images = snapshot.data!;

        return SizedBox(
          height: 250,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final imageUrl = images[index].data['imageUrl'];
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    // Tambahkan loading builder untuk pengalaman yang lebih baik
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    // Tambahkan error builder jika gambar gagal dimuat
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
              // Indikator titik-titik (dots)
              if (images.length > 1)
                Positioned(
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (index) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 2.0,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
