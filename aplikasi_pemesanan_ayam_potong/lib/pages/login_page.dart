// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

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
  bool _isErrorVisible = false;
  String _errorMessage = "";

  void _login() async {
    setState(() {
      _isLoading = true;
      _isErrorVisible = false; // Sembunyikan error saat proses dimulai
    });
    
    try {
      final session = await widget.authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final role = await widget.databaseService.getUserRole(session.userId);

      if (mounted) {
        if (role == 'admin') {
          // Ganti semua rute sebelumnya dengan admin dashboard
          Navigator.of(context).pushNamedAndRemoveUntil('/admin-dashboard', (route) => false);
        } else {
          // Ganti semua rute sebelumnya dengan customer dashboard
          Navigator.of(context).pushNamedAndRemoveUntil('/customer-dashboard', (route) => false);
        }
      }
    } on AppwriteException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Terjadi kesalahan tidak diketahui.';
        _isErrorVisible = true; // Tampilkan pesan error
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
      // Atur background dan hindari keyboard menutupi UI
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(40, 38, 56, 1),
      body: SingleChildScrollView(
        reverse: true,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 60),

            // Judul "Login"
            const Center(
              child: SizedBox(
                height: 200,
                width: 400,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

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
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Email", // Diubah dari Username menjadi Email
                        contentPadding: EdgeInsets.all(20)),
                    keyboardType: TextInputType.emailAddress,
                    onTap: () => setState(() => _isErrorVisible = false),
                  ),
                  const Divider(thickness: 2, height: 0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Password",
                        contentPadding: const EdgeInsets.all(20),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _isObscure = !_isObscure),
                        )),
                    onTap: () => setState(() => _isErrorVisible = false),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Tombol Login
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),

            // Link ke Halaman Register
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: const Text.rich(
                  TextSpan(
                    text: "Belum punya akun? ",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    children: [
                      TextSpan(
                        text: "Daftar di sini",
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}