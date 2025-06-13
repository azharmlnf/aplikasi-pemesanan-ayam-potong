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

  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi semua controller dengan data produk yang ada
    final productData = widget.product.data;
    _nameController.text = productData['name'] ?? '';
    _descriptionController.text = productData['description'] ?? '';
    _priceController.text = (productData['price'] ?? 0.0).toString();
    _stockController.text = (productData['stock'] ?? 0).toString();
    _existingImageUrl = productData['imageUrl'] as String?;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Panggil fungsi update, kirim gambar baru jika ada (bisa null)
      await widget.databaseService.updateProduct(
        documentId: widget.product.$id,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        imageFile: _selectedImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Produk berhasil diperbarui!'),
            backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memperbarui: $e'),
          backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildImageWidget() {
    // Prioritaskan gambar baru yang dipilih
    if (_selectedImage != null) {
      return Image.file(_selectedImage!, fit: BoxFit.cover);
    }
    // Jika tidak ada gambar baru, tampilkan gambar lama
    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return Image.network(_existingImageUrl!, fit: BoxFit.cover);
    }
    // Jika tidak ada keduanya, tampilkan placeholder
    return const Center(child: Icon(Icons.inventory_2, size: 50, color: Colors.grey));
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
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8.0)),
                  child: _buildImageWidget(),
                ),
              ),
              const SizedBox(height: 20),
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
}