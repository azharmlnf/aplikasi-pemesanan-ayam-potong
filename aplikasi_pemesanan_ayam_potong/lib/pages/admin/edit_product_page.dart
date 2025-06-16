// lib/pages/admin/edit_product_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/database_service.dart';

class EditProductPage extends StatefulWidget {
  final DatabaseService databaseService;
  final models.Document product;

  const EditProductPage({
    Key? key,
    required this.databaseService,
    required this.product,
  }) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  // State untuk gambar
  late Future<List<models.Document>> _existingImagesFuture;
  List<File> _newImages = []; // Untuk menyimpan gambar baru yang dipilih

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final productData = widget.product.data;
    _nameController.text = productData['name'] ?? '';
    _descriptionController.text = productData['description'] ?? '';
    _priceController.text = (productData['price'] ?? 0.0).toString();
    _stockController.text = (productData['stock'] ?? 0).toString();
    _refreshExistingImages();
  }

  void _refreshExistingImages() {
    setState(() {
      _existingImagesFuture = widget.databaseService.getProductImages(widget.product.$id);
    });
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. Update data produk (nama, harga, dll)
      await widget.databaseService.updateProduct(
        documentId: widget.product.$id,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
      );

      // 2. Upload gambar-gambar baru yang dipilih
      for (var imageFile in _newImages) {
        await widget.databaseService.addImageToProduct(widget.product.$id, imageFile);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil diperbarui!'), backgroundColor: Colors.green));
        Navigator.pop(context, true); // Kirim sinyal refresh
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- AREA UNTUK GAMBAR ---
              const Text("Gambar Produk", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildImageManagementSection(),
              
              const SizedBox(height: 20),
              // --- SISA FORM ---
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Produk'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Deskripsi'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProduct,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Update Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan semua gambar (lama dan baru)
  Widget _buildImageManagementSection() {
    return Container(
      height: 120,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: FutureBuilder<List<models.Document>>(
        future: _existingImagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Gagal memuat gambar"));
          }
          
          final existingImages = snapshot.data ?? [];
          
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: existingImages.length + _newImages.length + 1, // +1 untuk tombol tambah
            itemBuilder: (context, index) {
              // Tombol Tambah Gambar
              if (index == existingImages.length + _newImages.length) {
                return _buildAddImageButton();
              }
              
              // Tampilkan Gambar yang Sudah Ada (Existing)
              if (index < existingImages.length) {
                final imageDoc = existingImages[index];
                return _buildImageThumbnail(
                  Image.network(imageDoc.data['imageUrl'], fit: BoxFit.cover),
                  onDelete: () async {
                    await widget.databaseService.deleteProductImage(imageDoc.$id, imageDoc.data['fileId']);
                    _refreshExistingImages(); // Refresh list gambar lama
                  }
                );
              }
              
              // Tampilkan Gambar Baru yang Dipilih (New)
              final newImageIndex = index - existingImages.length;
              return _buildImageThumbnail(
                Image.file(_newImages[newImageIndex], fit: BoxFit.cover),
                onDelete: () {
                  setState(() => _newImages.removeAt(newImageIndex));
                }
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100, margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_a_photo_outlined, color: Colors.grey),
          SizedBox(height: 4), Text("Tambah", style: TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }

  Widget _buildImageThumbnail(Widget imageWidget, {required VoidCallback onDelete}) {
    return Container(
      width: 100, margin: const EdgeInsets.all(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8.0), child: imageWidget),
          Positioned(
            top: -10, right: -10,
            child: IconButton(
              onPressed: onDelete,
              icon: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, color: Colors.white, size: 14)),
            ),
          ),
        ],
      ),
    );
  }
}