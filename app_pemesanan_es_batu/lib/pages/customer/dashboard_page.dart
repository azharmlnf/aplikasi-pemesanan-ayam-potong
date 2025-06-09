import 'package:flutter/material.dart';
import '../../services/auth_service.dart';


class CustomerDashboardPage extends StatelessWidget {
  final AuthService authService;
  const CustomerDashboardPage({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Selamat Datang, Pelanggan!'),
      ),
    );
  }
}