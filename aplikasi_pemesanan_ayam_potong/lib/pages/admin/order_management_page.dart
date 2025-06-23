// lib/pages/admin/order_management_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/database_service.dart';
import '../../widgets/order_card.dart'; // <-- Import OrderCard dari lokasi baru
import 'order_detail_page.dart';

class OrderManagementPage extends StatefulWidget {
  final DatabaseService databaseService;
  const OrderManagementPage({Key? key, required this.databaseService}) : super(key: key);

  @override
  _OrderManagementPageState createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  // Ubah _ordersFuture agar bisa null pada awalnya
  Future<List<models.Document>>? _ordersFuture;

  final Map<String, String> _customerNameCache = {};

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk memuat data pertama kali
    _loadOrders();
  }
  
  // Fungsi terpisah untuk memuat data
  void _loadOrders() {
    setState(() {
      _ordersFuture = widget.databaseService.getOrders();
    });
  }

  // Fungsi yang dipanggil oleh RefreshIndicator
  Future<void> _handleRefresh() async {
    // Tidak perlu setState di sini karena RefreshIndicator
    // akan otomatis membangun ulang setelah Future selesai.
    // Kita hanya perlu me-reset cache jika diperlukan dan mengambil data baru.
    _customerNameCache.clear();
    setState(() {
      _ordersFuture = widget.databaseService.getOrders();
    });
  }

  Future<String> _getCustomerName(String userId) async {
    if (_customerNameCache.containsKey(userId)) return _customerNameCache[userId]!;
    
    final profile = await widget.databaseService.getProfile(userId);
    final name = profile?.data['name'] ?? 'Customer Dihapus';
    _customerNameCache[userId] = name;
    return name;
  }
 // <<< FUNGSI BARU UNTUK MENANGANI PERUBAHAN STATUS >>>
  Future<void> _changeOrderStatus(String orderId, String newStatus) async {
    try {
      // Tampilkan loading indicator kecil atau abaikan
      await widget.databaseService.updateOrderStatus(orderId, newStatus);
      
      // Tampilkan notifikasi sukses
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pesanan berhasil diubah menjadi $newStatus.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh daftar pesanan untuk menampilkan status baru
   _loadOrders(); // <-- PANGGIL NAMA FUNGSI YANG BENAR
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh, // Panggil fungsi refresh yang benar
        child: FutureBuilder<List<models.Document>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Tidak ada pesanan masuk.', style: TextStyle(fontSize: 18, color: Colors.grey)));
            }

            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final customerId = order.data['customerId'];

                return FutureBuilder<String>(
                  future: _getCustomerName(customerId),
                  builder: (context, nameSnapshot) {
                    if (nameSnapshot.connectionState == ConnectionState.waiting) {
                      return const Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SizedBox(height: 130, child: Center(child: CircularProgressIndicator())),
                      );
                    }
                    final customerName = nameSnapshot.data ?? 'Nama Tidak Ditemukan';
                    
                    // LOGIKA NAVIGASI DILAKUKAN DI SINI (DI PARENT)
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailPage(
                              order: order,
                              customerName: customerName,
                              databaseService: widget.databaseService,
                            ),
                          ),
                        );
                      },
child: OrderCard(
                        order: order,
                        customerName: customerName,
                        // --- KIRIM FUNGSI SEBAGAI PARAMETER ---
                        onStatusChanged: (newStatus) {
                          _changeOrderStatus(order.$id, newStatus);
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}