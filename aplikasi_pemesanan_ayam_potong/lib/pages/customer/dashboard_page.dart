// lib/pages/customer/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../common/profile_page.dart';

class CustomerDashboardPage extends StatefulWidget {
  final AuthService authService;
  final DatabaseService databaseService; // Terima DatabaseService

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

    // Halaman untuk customer (bisa Anda kembangkan nanti)
    _pages = [
      const Center(child: Text('Halaman Produk Customer')), // Placeholder
      const Center(child: Text('Halaman Riwayat Pesanan')), // Placeholder
      ProfilePage(authService: widget.authService, userProfile: _userProfile),
    ];
  }

  Future<void> _loadUserProfile() async {
    final user = await widget.authService.getCurrentUser();
    if (user != null) {
      final profile = await widget.databaseService.getProfile(user.$id);
      setState(() {
        _userProfile = profile;
        _pages[2] = ProfilePage(
          authService: widget.authService,
          userProfile: _userProfile,
        );
      });
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
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}