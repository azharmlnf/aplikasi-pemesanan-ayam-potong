// lib/pages/admin/order_detail_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/database_service.dart';
import '../../services/auth_service.dart'; 
import '../../services/pdf_service.dart';

class OrderDetailPage extends StatefulWidget {
  final models.Document order;
  final String customerName;
  final DatabaseService databaseService;
  final AuthService authService;

  const OrderDetailPage({
    Key? key,
    required this.order,
    required this.customerName,
    required this.databaseService,
    required this.authService,
  }) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<List<models.Document>> _orderItemsFuture;
  late final PdfService _pdfService; // Deklarasi sudah benar

  @override
  void initState() {
    super.initState();
    // --- INISIALISASI PDF SERVICE DI SINI ---
    _pdfService = PdfService(databaseService: widget.databaseService);
    
    _orderItemsFuture = widget.databaseService.getOrderItems(widget.order.$id);
  }
  
  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final orderData = widget.order.data;
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan #${widget.order.$id.substring(0, 8)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () async {
              // Pastikan widget masih ada sebelum melanjutkan
              if (!mounted) return;
              
              // Tampilkan loading indicator kecil
              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(const SnackBar(content: Text('Membuat PDF...'), duration: Duration(seconds: 10)));
              
              try {
                final items = await _orderItemsFuture;
                // Ganti nama fungsi menjadi yang lebih spesifik
                await _pdfService.createSingleOrderPdf(
                  order: widget.order,
                  orderItems: items,
                  customerName: widget.customerName,
                );
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Gagal membuat PDF: $e'), backgroundColor: Colors.red));
              } finally {
                messenger.hideCurrentSnackBar();
              }
            },
            tooltip: 'Ekspor ke PDF',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- INFORMASI UMUM PESANAN ---
            _buildOrderSummaryCard(orderData),
            const SizedBox(height: 24),

            // --- DAFTAR ITEM YANG DIPESAN ---
            Text(
              'Item yang Dipesan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildOrderItemsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(Map<String, dynamic> orderData) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Nama Pelanggan:', widget.customerName),
            _buildInfoRow('Tanggal Pesan:', _formatDate(widget.order.$createdAt)),
            _buildInfoRow('Status:', (orderData['status'] ?? 'N/A').toUpperCase()),
            _buildInfoRow('Total Bayar:', 'Rp ${orderData['totalPrice']?.toStringAsFixed(0) ?? '0'}', isTotal: true),
            if (orderData['description'] != null && orderData['description'].isNotEmpty)
              _buildInfoRow('Catatan:', orderData['description']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return FutureBuilder<List<models.Document>>(
      future: _orderItemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat item: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada item dalam pesanan ini.'));
        }

        final items = snapshot.data!;
        // Gunakan Column karena ListView di dalam SingleChildScrollView butuh tinggi tetap
        return Column(
          children: items.map((item) {
            final itemData = item.data;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(itemData['name'] ?? 'Nama Produk Tidak Ada'),
                subtitle: Text('Potong ${itemData['pieces']}'),
                leading: CircleAvatar(
                  child: Text('x${itemData['quantity']}'),
                ),
                trailing: Text(
                  'Rp ${(itemData['priceAtOrder'] ?? 0.0).toStringAsFixed(0)}',
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}