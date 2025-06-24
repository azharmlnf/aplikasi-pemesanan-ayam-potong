// lib/pages/customer/my_orders_page.dart

import 'package:app_pemesanan_ayam_potong/pages/admin/order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/order_card.dart';

import '../common/product_detail_page.dart';

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
  
  // --- STATE BARU UNTUK FILTER ---
  String? _activeStatusFilter;
  final List<String> _statusOptions = ['pending', 'processed', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    loadMyOrders();
  }

  // Perbarui fungsi ini untuk menggunakan filter
  Future<void> loadMyOrders() async {
    final user = await widget.authService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _myOrdersFuture = widget.databaseService.getMyOrders(user.$id, statusFilter: _activeStatusFilter);
      });
    }
  }

  // Fungsi yang dipanggil saat chip filter ditekan
  void _onFilterSelected(String? status) {
    setState(() {
      if (_activeStatusFilter == status) {
        _activeStatusFilter = null;
      } else {
        _activeStatusFilter = status;
      }
      loadMyOrders();
    });
  }

  void _navigateToDetailPage(models.Document order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailPage(
          order: order,
          customerName: "Detail Pesanan Anda",
          databaseService: widget.databaseService,
          authService: widget.authService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bungkus body dengan Column
      body: Column(
        children: [
          // Tampilkan UI Filter
          _buildFilterChips(),

          // Gunakan Expanded untuk ListView
          Expanded(
            child: RefreshIndicator(
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
                    final filterText = _activeStatusFilter != null ? 'dengan status "$_activeStatusFilter"' : '';
                    return Center(child: Text('Anda belum memiliki pesanan $filterText.', style: const TextStyle(fontSize: 18, color: Colors.grey)));
                  }

                  final myOrders = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    itemCount: myOrders.length,
                    itemBuilder: (context, index) {
                      final order = myOrders[index];
                      final customerName = "Pesanan Saya";
                      return OrderCard(
                        order: order,
                        customerName: customerName,
                        onTap: () => _navigateToDetailPage(order),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget baru untuk membuat baris filter
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: const Text('Semua'),
                selected: _activeStatusFilter == null,
                onSelected: (selected) => _onFilterSelected(null),
                selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(color: _activeStatusFilter == null ? Colors.white : Colors.black),
              ),
            ),
            ..._statusOptions.map((status) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(status.replaceFirst(status[0], status[0].toUpperCase())),
                  selected: _activeStatusFilter == status,
                  onSelected: (selected) => _onFilterSelected(status),
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(color: _activeStatusFilter == status ? Colors.white : Colors.black),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}