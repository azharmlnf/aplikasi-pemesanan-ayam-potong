// lib/pages/customer/my_orders_page.dart

import 'package:app_pemesanan_ayam_potong/pages/admin/order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/order_card.dart';
import '../../services/pdf_service.dart';
import '../common/product_detail_page.dart'; // Hanya perlu import ini, bukan dari admin/

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
  late final PdfService _pdfService; // Deklarasikan di sini
  String? _activeStatusFilter;
  final List<String> _statusOptions = [
    'pending',
    'processed',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _pdfService = PdfService(
      databaseService: widget.databaseService,
    ); // Inisialisasi
    loadMyOrders();
  }

  // Perbarui fungsi ini untuk menggunakan filter
  Future<void> loadMyOrders() async {
    final user = await widget.authService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _myOrdersFuture = widget.databaseService.getMyOrders(
          user.$id,
          statusFilter: _activeStatusFilter,
        );
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

  void _navigateToDetailPage(models.Document order) async {
    await Navigator.push(
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
    loadMyOrders(); // Refresh saat kembali dari detail
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
                    final filterText = _activeStatusFilter != null
                        ? 'dengan status "$_activeStatusFilter"'
                        : '';
                    return Center(
                      child: Text(
                        'Anda belum memiliki pesanan $filterText.',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    );
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
      floatingActionButton: FloatingActionButton(
        // --- LOGIKA onPressed YANG DIPERBARUI ---
        onPressed: () async {
          // 1. Ambil data pesanan terlebih dahulu
          final ordersToExport = await _myOrdersFuture;

          // 2. Validasi jika ada data untuk diekspor
          if (ordersToExport == null || ordersToExport.isEmpty) {
            if (mounted)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tidak ada riwayat untuk diekspor.'),
                ),
              );
            return;
          }

          // 3. Tampilkan dialog loading
          showDialog(
            context: context,
            barrierDismissible:
                false, // User tidak bisa menutup dialog dengan menekan di luar
            builder: (BuildContext context) {
              return const Dialog(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text("Mengunduh Riwayat..."),
                    ],
                  ),
                ),
              );
            },
          );

          try {
            // 4. Lakukan proses pembuatan PDF
            final user = await widget.authService.getCurrentUser();
            final customerName = user?.name ?? 'Pelanggan';
            await _pdfService.createOrderHistoryPdf(
              orders: ordersToExport,
              reportTitle: 'Riwayat Pesanan Saya',
              generatedBy: customerName,
            );
          } catch (e) {
            if (mounted)
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Gagal membuat PDF: $e')));
          } finally {
            // 5. SELALU tutup dialog loading setelah proses selesai (baik berhasil maupun gagal)
            if (mounted) Navigator.of(context).pop();
          }
        },
        child: const Icon(Icons.picture_as_pdf_outlined),
        tooltip: 'Unduh Riwayat (PDF)',
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
                labelStyle: TextStyle(
                  color: _activeStatusFilter == null
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            ..._statusOptions.map((status) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(
                    status.replaceFirst(status[0], status[0].toUpperCase()),
                  ),
                  selected: _activeStatusFilter == status,
                  onSelected: (selected) => _onFilterSelected(status),
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: _activeStatusFilter == status
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
