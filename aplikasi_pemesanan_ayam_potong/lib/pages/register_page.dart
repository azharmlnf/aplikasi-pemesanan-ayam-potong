import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final AuthService authService;

  const RegisterPage({Key? key, required this.authService}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

   void _register() async {
    setState(() => _isLoading = true);
    try {
      await widget.authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        username: _usernameController.text,
        phoneNumber: _phoneController.text,
      );
      
      if (mounted) {
        // Karena user sudah otomatis login, langsung arahkan ke dashboard customer
        Navigator.pushNamedAndRemoveUntil(context, '/customer-dashboard', (route) => false);
      }

    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Terjadi kesalahan')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Nomor HP')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _register, child: const Text('Daftar')),
          ],
        ),
      ),
    );
  }
}