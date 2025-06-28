// lib/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final AuthService authService;

  const RegisterPage({Key? key, required this.authService}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reenterPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscure1 = true;
  bool _isObscure2 = true;
  String _errorMessage = "";

  void _register() async {
    FocusScope.of(context).unfocus();
    // Validasi form sebelum mengirim
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      await widget.authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/customer-dashboard', (route) => false);
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
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _reenterPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFFC700);
    const secondaryTextColor = Colors.grey;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Tombol kembali berwarna hitam
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Buat Akun Baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isi data diri Anda untuk memulai',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: secondaryTextColor),
                ),
                const SizedBox(height: 30),

                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ),

                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nama Lengkap', prefixIcon: const Icon(Icons.badge_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  onTap: () => setState(() => _errorMessage = ""),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username', prefixIcon: const Icon(Icons.alternate_email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  validator: (value) => value!.isEmpty ? 'Username tidak boleh kosong' : null,
                  onTap: () => setState(() => _errorMessage = ""),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? 'Email tidak boleh kosong' : null,
                  onTap: () => setState(() => _errorMessage = ""),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Nomor HP', prefixIcon: const Icon(Icons.phone_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Nomor HP tidak boleh kosong' : null,
                  onTap: () => setState(() => _errorMessage = ""),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure1,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(icon: Icon(_isObscure1 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _isObscure1 = !_isObscure1)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                    if (value.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  },
                  onTap: () => setState(() => _errorMessage = ""),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reenterPasswordController,
                  obscureText: _isObscure2,
                  decoration: InputDecoration(
                    labelText: 'Ulangi Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(icon: Icon(_isObscure2 ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _isObscure2 = !_isObscure2)),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) return 'Password tidak cocok';
                    return null;
                  },
                  onTap: () => setState(() => _errorMessage = ""),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Daftar", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text.rich(
                    TextSpan(
                      text: "Sudah punya akun? ",
                      style: const TextStyle(color: secondaryTextColor, fontSize: 15),
                      children: [
                        TextSpan(
                          text: "Masuk di sini",
                          style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}