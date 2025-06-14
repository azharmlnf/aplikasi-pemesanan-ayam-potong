// lib/pages/register_page.dart

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
  final _reenterPasswordController = TextEditingController(); // Untuk konfirmasi
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _isObscure1 = true;
  bool _isObscure2 = true;
  bool _isErrorVisible = false;
  String _errorMessage = "";

  void _register() async {
    // Validasi sederhana
    if (_passwordController.text != _reenterPasswordController.text) {
      setState(() {
        _errorMessage = "Password tidak cocok.";
        _isErrorVisible = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isErrorVisible = false;
    });

    try {
      await widget.authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        username: _usernameController.text,
        phoneNumber: _phoneController.text,
      );
      
      if (mounted) {
        // Karena user sudah otomatis login setelah registrasi, langsung arahkan
        Navigator.of(context).pushNamedAndRemoveUntil('/customer-dashboard', (route) => false);
      }
    } on AppwriteException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Terjadi kesalahan tidak diketahui.';
        _isErrorVisible = true;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(40, 38, 56, 1),
      appBar: AppBar( // Tambahkan AppBar agar mudah kembali
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Judul "Daftar Akun"
            const Center(
              child: SizedBox(
                height: 150, // Dikecilkan agar muat
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Daftar Akun",
                    style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            // Pesan Error
            Visibility(
              visible: _isErrorVisible,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),

            // Form Input
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: Colors.white),
              child: Column(
                children: <Widget>[
                  // MENAMBAHKAN FIELD-FIELD BARU
                  TextFormField(controller: _nameController, decoration: const InputDecoration(border: InputBorder.none, hintText: "Nama Lengkap", contentPadding: EdgeInsets.all(20))),
                  const Divider(thickness: 2, height: 0),
                  TextFormField(controller: _usernameController, decoration: const InputDecoration(border: InputBorder.none, hintText: "Username", contentPadding: EdgeInsets.all(20))),
                  const Divider(thickness: 2, height: 0),
                  TextFormField(controller: _emailController, decoration: const InputDecoration(border: InputBorder.none, hintText: "Email", contentPadding: EdgeInsets.all(20)), keyboardType: TextInputType.emailAddress),
                  const Divider(thickness: 2, height: 0),
                  TextFormField(controller: _phoneController, decoration: const InputDecoration(border: InputBorder.none, hintText: "Nomor HP", contentPadding: EdgeInsets.all(20)), keyboardType: TextInputType.phone),
                  const Divider(thickness: 2, height: 0),
                  // Password Fields dari template
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscure1,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Password",
                        contentPadding: const EdgeInsets.all(20),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure1 ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isObscure1 = !_isObscure1),
                        )),
                  ),
                  const Divider(thickness: 2, height: 0),
                  TextFormField(
                    controller: _reenterPasswordController,
                    obscureText: _isObscure2,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Ulangi Password",
                        contentPadding: const EdgeInsets.all(20),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure2 ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isObscure2 = !_isObscure2),
                        )),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Tombol Daftar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Daftar", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}