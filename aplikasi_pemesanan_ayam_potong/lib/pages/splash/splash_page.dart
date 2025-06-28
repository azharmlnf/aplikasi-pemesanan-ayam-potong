// lib/pages/splash_page.dart

import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Pindah ke halaman pengecekan login setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- Definisikan warna dari logo Anda ---
    const primaryColor = Color(0xFFFFC700);

    return Scaffold(
      // --- Ubah warna background menjadi putih ---
      backgroundColor: Colors.white, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tampilkan logo Anda
            Image.asset(
              'assets/images/logo.jpg', // --- Gunakan nama file yang benar ---
              width: 180, // Ukuran bisa disesuaikan
            ),
            const SizedBox(height: 24),
            const Text(
              'Aplikasi Pemesanan Ayam Potong',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Ubah warna teks agar terlihat di background putih
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Jasa Pemotongan Daging Ayam',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey, // Warna teks sekunder
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              // Ubah warna loading indicator agar sesuai
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor), 
            ),
          ],
        ),
      ),
    );
  }
}