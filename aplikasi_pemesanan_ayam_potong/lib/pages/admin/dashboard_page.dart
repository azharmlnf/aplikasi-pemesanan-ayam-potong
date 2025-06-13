// lib/pages/admin/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../common/profile_page.dart';
import 'product_management_page.dart';
import 'order_management_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final AuthService authService;
  final DatabaseService databaseService;

  const AdminDashboardPage({
    Key? key,
    required this.authService,
    required this.databaseService,
  }) : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  models.Document? _userProfile;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    // Inisialisasi daftar halaman
    _pages = [
      ProductManagementPage(databaseService: widget.databaseService),
      OrderManagementPage(databaseService: widget.databaseService),
      ProfilePage(authService: widget.authService, userProfile: _userProfile), // Awalnya null
    ];
  }

  // Fungsi untuk mengambil data profil
  Future<void> _loadUserProfile() async {
    final user = await widget.authService.getCurrentUser();
    if (user != null) {
      final profile = await widget.databaseService.getProfile(user.$id);
      setState(() {
        _userProfile = profile;
        // Update halaman profil di dalam list dengan data yang sudah didapat
        _pages[2] = ProfilePage(
          authService: widget.authService,
          userProfile: _userProfile,
        );
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Judul AppBar yang dinamis
  final List<String> _pageTitles = ['Manajemen Produk', 'Manajemen Pesanan', 'Profil Saya'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}