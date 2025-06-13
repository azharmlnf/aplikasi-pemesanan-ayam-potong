// lib/pages/common/profile_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  final AuthService authService;
  final models.Document? userProfile;

  const ProfilePage({
    Key? key,
    required this.authService,
    required this.userProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading jika data profil belum siap
    if (userProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profileData = userProfile!.data;
    final role = profileData['role'] ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Akun',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Username'),
                    subtitle: Text(
                      profileData['username'] ?? 'Tidak ada data',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Nama Lengkap'),
                    subtitle: Text(
                      profileData['name'] ?? 'Tidak ada data',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: const Text('Peran Akun'),
                    subtitle: Chip(
                      label: Text(
                        role.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: role == 'admin' ? Colors.teal : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(), // Mendorong tombol ke bawah
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () async {
                await authService.logout();
                // Kembali ke halaman login dan hapus semua rute sebelumnya
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}