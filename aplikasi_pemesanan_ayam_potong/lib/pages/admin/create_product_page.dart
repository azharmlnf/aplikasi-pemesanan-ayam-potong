// lib/pages/admin/create_product_page.dart

import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class CreateProductPage extends StatefulWidget {
  final DatabaseService databaseService;

  const CreateProductPage({Key? key, required this.databaseService}) : super(key: key);

  @override
  _CreateProductPageState createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  bool _isLoading = false;



Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) return;
    // Hapus validasi gambar
    
    setState(() => _isLoading = true);

    try {
      // Panggil fungsi tanpa imageFile
      await widget.databaseService.createProduct(
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Produk berhasil ditambahkan!'),
            backgroundColor: Colors.green));
        Navigator.pop(context, true); // Kirim sinyal untuk refresh
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal membuat produk: $e'),
          backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              const SizedBox(height: 20),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Produk'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Deskripsi'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _createProduct,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Simpan Produk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}