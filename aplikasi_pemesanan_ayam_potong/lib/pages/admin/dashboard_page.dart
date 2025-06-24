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
  
  // --- PERUBAHAN STATE ---
  bool _isLoadingProfile = true; // State baru untuk menandakan sedang loading
  models.Document? _userProfile;
  // ---

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inisialisasi halaman dengan data awal (kosong/placeholder)
    _pages = [
      ProductManagementPage(databaseService: widget.databaseService, userRole: '', authService: widget.authService, ), // Role awal kosong
OrderManagementPage(
        databaseService: widget.databaseService,
        authService: widget.authService,
      ),      ProfilePage(authService: widget.authService, userProfile: null),
    ];
    // Panggil fungsi untuk memuat data
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = await widget.authService.getCurrentUser();
    if (user != null) {
      final profile = await widget.databaseService.getProfile(user.$id);
      
      // Setelah data didapat, panggil setState
      if (mounted) {
        setState(() {
          _userProfile = profile;
          // Update halaman yang membutuhkan data profil
          _pages[0] = ProductManagementPage(databaseService: widget.databaseService, userRole: _userProfile?.data['role'] ?? 'customer', authService: widget.authService, );
          _pages[2] = ProfilePage(authService: widget.authService, userProfile: _userProfile);
          _isLoadingProfile = false; // Set loading menjadi false setelah selesai
        });
      }
    } else {
      // Handle jika user tidak ditemukan (seharusnya tidak terjadi di halaman ini)
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<String> _pageTitles = ['Manajemen Produk', 'Manajemen Pesanan', 'Profil Saya'];

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA UTAMA ADA DI SINI ---

    // 1. Jika masih loading, tampilkan CircularProgressIndicator
    if (_isLoadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Tentukan apakah user adalah admin SETELAH loading selesai
    final bool isUserAdmin = _userProfile?.data['role'] == 'admin';

    // 3. Jika bukan admin, tampilkan pesan akses ditolak
    if (!isUserAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Akses Ditolak')),
        body: const Center(
          child: Text(
            'Akses Ditolak. Anda bukan admin.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    // 4. Jika semua pemeriksaan lolos (loading selesai DAN user adalah admin), tampilkan dashboard
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