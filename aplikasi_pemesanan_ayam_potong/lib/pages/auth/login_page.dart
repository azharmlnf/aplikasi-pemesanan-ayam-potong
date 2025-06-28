// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class LoginPage extends StatefulWidget {
  final AuthService authService;
  final DatabaseService databaseService;

  const LoginPage({
    Key? key,
    required this.authService,
    required this.databaseService,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isObscure = true;
  String _errorMessage = "";

  void _login() async {
    FocusScope.of(context).unfocus(); // Sembunyikan keyboard
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() => _errorMessage = "Email dan Password tidak boleh kosong.");
        return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    
    try {
      final session = await widget.authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final role = await widget.databaseService.getUserRole(session.userId);

      if (mounted) {
        if (role == 'admin') {
          Navigator.of(context).pushNamedAndRemoveUntil('/admin-dashboard', (route) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil('/customer-dashboard', (route) => false);
        }
      }
    } on AppwriteException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Terjadi kesalahan tidak diketahui.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definisikan warna utama agar mudah digunakan kembali
    const primaryColor = Color(0xFFFFC700);
    const secondaryTextColor = Colors.grey;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Bagian Logo
              Image.asset(
                'assets/images/logo.jpg', // Pastikan path ini benar
                height: 120,
              ),
              const SizedBox(height: 20),

              // Bagian Judul
              const Text(
                'Selamat Datang Kembali',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              const SizedBox(height: 40),

              // Pesan Error
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              // Form Input Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onTap: () => setState(() => _errorMessage = ""),
              ),
              const SizedBox(height: 16),

              // Form Input Password
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
                onTap: () => setState(() => _errorMessage = ""),
              ),
              const SizedBox(height: 24),

              // Tombol Login
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              // Link ke Halaman Register
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: Text.rich(
                  TextSpan(
                    text: "Belum punya akun? ",
                    style: const TextStyle(color: secondaryTextColor, fontSize: 15),
                    children: [
                      TextSpan(
                        text: "Daftar di sini",
                        style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}