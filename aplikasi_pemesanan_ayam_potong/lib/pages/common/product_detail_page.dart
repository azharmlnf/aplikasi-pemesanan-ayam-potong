// lib/pages/common/product_detail_page.dart
// lib/pages/common/product_detail_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../admin/edit_product_page.dart'; // <-- PASTIKAN IMPORT INI ADA

class ProductDetailPage extends StatefulWidget {
  final models.Document product;
  final DatabaseService databaseService;
  final String userRole;

  const ProductDetailPage({
    Key? key,
    required this.product,
    required this.databaseService,
    required this.userRole,
  }) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<List<models.Document>> _imagesFuture;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

 // <<< TAMBAHKAN FUNGSI BARU INI >>>
  void _navigateToEditPage() async {
    // Navigasi ke EditProductPage dan TUNGGU hasilnya
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(
          databaseService: widget.databaseService,
          product: widget.product, // Kirim data produk saat ini
        ),
      ),
    );

    // Jika halaman edit mengembalikan 'true' (artinya ada perubahan),
    // kita perlu memberitahu halaman sebelumnya (product management) untuk refresh.
    // Cara termudah adalah dengan menutup halaman detail ini juga.
    if (result == true) {
      // Kembali ke halaman daftar produk agar bisa melihat perubahan
      if (mounted) Navigator.pop(context, true);
    }
  }

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

  // --- FUNGSI UNTUK MENAMPILKAN FORM DI BOTTOMSHEET (DIPERBAIKI) ---
  void _showAddToCartForm() async {
  // --- UBAH TIPE DATA DI SINI ---
  // Ganti Map<String, int> menjadi Map<String, int?>
  final result = await showModalBottomSheet<Map<String, int?>>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return AddToCartForm(pieceOptions: const [1, 2, 4, 6, 8]);
    },
  );

  // Cek jika pengguna menutup sheet tanpa konfirmasi (result == null)
  if (result == null) return;

  // Sekarang 'result' sudah benar bertipe Map<String, int?>
  final quantity = result['quantity'];
  final pieces = result['pieces'];

  // Validasi tetap penting
  if (quantity != null && pieces != null) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem(
      productDoc: widget.product,
      quantity: quantity,
      pieces: pieces,
    );

      // Tampilkan SnackBar menggunakan context dari ProductDetailPage yang valid
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Produk ditambahkan!'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'LIHAT',
            textColor: Colors.amber,
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productData = widget.product.data;

    return Scaffold(
      appBar: AppBar(
        title: Text(productData['name'] ?? 'Detail Produk'),
        actions: widget.userRole == 'admin'
            ? [
                IconButton(
                  icon: const Icon(Icons.edit_note),
                  // Panggil fungsi navigasi yang baru kita buat
                  onPressed: _navigateToEditPage, 
                  tooltip: 'Edit Produk',
                )
              ]
            : null,
      ),
      body: SingleChildScrollView(
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
                  Text('Deskripsi Produk', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    productData['description'] ?? 'Tidak ada deskripsi.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionButton(),
    );
  }

  Widget? _buildBottomActionButton() {
  // Jika peran pengguna adalah 'customer', kembalikan tombol.
  if (widget.userRole == 'customer') {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Tambah ke Keranjang'),
        onPressed: _showAddToCartForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  
  // --- TAMBAHKAN BARIS INI ---
  // Jika bukan 'customer' (misalnya admin), kembalikan null secara eksplisit.
  return null; 
}
  // Widget untuk galeri gambar (tidak ada perubahan)
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
                onPageChanged: (index) =>
                    setState(() => _currentImageIndex = index),
                itemBuilder: (context, index) {
                  final imageUrl = images[index].data['imageUrl'];
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
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
              if (images.length > 1)
                Positioned(
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (index) => Container(
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
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
// --- WIDGET BARU & TERPISAH UNTUK FORM DI BOTTOM SHEET ---
class AddToCartForm extends StatefulWidget {
  final List<int> pieceOptions;
  const AddToCartForm({Key? key, required this.pieceOptions}) : super(key: key);

  @override
  _AddToCartFormState createState() => _AddToCartFormState();
}

class _AddToCartFormState extends State<AddToCartForm> {
  final _formKey = GlobalKey<FormState>(); // Tambahkan GlobalKey untuk validasi
  int _quantity = 1;
  int? _selectedPieces;

  void _submitForm() {
    // Jalankan validasi pada Dropdown
    if (!_formKey.currentState!.validate()) {
      // Jika tidak valid (null), validasi akan otomatis menampilkan pesan error
      return;
    }
    // Jika valid, kembalikan data
    Navigator.pop(context, {'quantity': _quantity, 'pieces': _selectedPieces});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      // Bungkus dengan Form agar bisa menggunakan validator
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Atur Pesanan", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Jumlah:", style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle), onPressed: () { if (_quantity > 1) setState(() => _quantity--); }),
                    Text("$_quantity", style: Theme.of(context).textTheme.titleLarge),
                    IconButton(icon: const Icon(Icons.add_circle), onPressed: () => setState(() => _quantity++)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 10),
            // --- DROPDOWN YANG DIPERBAIKI DENGAN VALIDATOR ---
            DropdownButtonFormField<int>(
              value: _selectedPieces,
              hint: const Text("Pilih Jumlah Potongan"),
              decoration: const InputDecoration(
                labelText: 'Dipotong Menjadi',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: widget.pieceOptions.map((pieces) =>
                DropdownMenuItem(value: pieces, child: Text(pieces == 1 ? '1 (Utuh Tidak Dipotong)' : '$pieces bagian')),
              ).toList(),
              onChanged: (value) => setState(() => _selectedPieces = value),
              // Validator akan menampilkan pesan error di bawah field jika null
              validator: (value) {
                if (value == null) {
                  return 'Harap pilih jumlah potongan.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // --- TOMBOL KONFIRMASI YANG DIPERBAIKI ---
            ElevatedButton(
              child: const Text('Konfirmasi'),
              onPressed: _submitForm, // Panggil fungsi submit
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
