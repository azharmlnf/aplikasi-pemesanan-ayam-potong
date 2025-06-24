// lib/pages/customer/my_orders_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/order_card.dart';
import '../admin/order_detail_page.dart'; // Hapus ini jika sudah dipindah ke common

class MyOrdersPage extends StatefulWidget {
  final AuthService authService;
  final DatabaseService databaseService;

  const MyOrdersPage({
    Key? key,
    required this.authService,
    required this.databaseService,
  }) : super(key: key);

  @override
  State<MyOrdersPage> createState() => MyOrdersPageState();
}

class MyOrdersPageState extends State<MyOrdersPage> {
  Future<List<models.Document>>? _myOrdersFuture;

  @override
  void initState() {
    super.initState();
    loadMyOrders(); // Ganti nama agar bisa dipanggil dari luar
  }

  Future<void> loadMyOrders() async {
    final user = await widget.authService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _myOrdersFuture = widget.databaseService.getMyOrders(user.$id);
      });
    }
  }

  // Fungsi navigasi ke detail
  void _navigateToDetailPage(models.Document order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailPage(
          order: order,
          customerName: "Detail Pesanan Anda",
          databaseService: widget.databaseService,
          authService: widget.authService, // Jangan lupa kirim authService
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: loadMyOrders,
        child: FutureBuilder<List<models.Document>>(
          future: _myOrdersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Anda belum memiliki riwayat pesanan.', style: TextStyle(fontSize: 18, color: Colors.grey)),
              );
            }

            final myOrders = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              itemCount: myOrders.length,
              itemBuilder: (context, index) {
                final order = myOrders[index];
                final customerName = "Pesanan Saya";

                // --- PEMANGGILAN YANG BENAR ---
                return OrderCard(
                  order: order,
                  customerName: customerName,
                  onTap: () => _navigateToDetailPage(order), // Tambahkan onTap di sini
                );
              },
            );
          },
        ),
      ),
    );
  }
}