// lib/pages/customer/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../common/profile_page.dart';
import 'product_list_page.dart';
import '../../widgets/cart_badge.dart'; // <-- 1. IMPORT WIDGET BADGE
import 'cart_page.dart';              // <-- 2. IMPORT HALAMAN KERANJANG

class CustomerDashboardPage extends StatefulWidget {
  final AuthService authService;
  final DatabaseService databaseService;

  const CustomerDashboardPage({
    Key? key,
    required this.authService,
    required this.databaseService,
  }) : super(key: key);

  @override
  _CustomerDashboardPageState createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  int _selectedIndex = 0;
  models.Document? _userProfile;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    // Halaman untuk customer
    _pages = [
      CustomerProductListPage(
        databaseService: widget.databaseService,
                authService: widget.authService, // <-- KIRIMKAN DI SINI
        userRole: 'customer',
      ),
      const Center(child: Text('Halaman Riwayat Pesanan')), // Placeholder
      ProfilePage(authService: widget.authService, userProfile: _userProfile),
    ];
  }

  Future<void> _loadUserProfile() async {
    final user = await widget.authService.getCurrentUser();
    if (user != null) {
      final profile = await widget.databaseService.getProfile(user.$id);
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _pages[2] = ProfilePage(
            authService: widget.authService,
            userProfile: _userProfile,
          );
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  final List<String> _pageTitles = ['Beranda', 'Pesanan Saya', 'Profil Saya'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        // --- BAGIAN YANG DIPERBARUI ---
        actions: <Widget>[
          // Tampilkan ikon keranjang hanya jika kita tidak berada di halaman profil
          if (_selectedIndex != 2)
            Padding(
              padding: const EdgeInsets.only(right: 8.0), // Beri sedikit jarak dari tepi
              child: CartBadge(
                onTap: () {
    // Gunakan MaterialPageRoute dan kirim service yang dibutuhkan
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => CartPage(
          authService: widget.authService,
          databaseService: widget.databaseService,
        ),
      ),
    );
  },
  child: const IconButton(
    icon: Icon(Icons.shopping_cart_outlined),
    tooltip: 'Keranjang Belanja',
    onPressed: null,
  ),
              ),
            ),
        ],
        // --- AKHIR BAGIAN YANG DIPERBARUI ---
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}