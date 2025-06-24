// lib/pages/admin/order_management_page.dart

import 'package:app_pemesanan_ayam_potong/pages/admin/order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/order_card.dart';

class OrderManagementPage extends StatefulWidget {
  final DatabaseService databaseService;
  final AuthService authService;

  const OrderManagementPage({
    Key? key,
    required this.databaseService,
    required this.authService,
  }) : super(key: key);

  @override
  _OrderManagementPageState createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  Future<List<models.Document>>? _ordersFuture;
  final Map<String, String> _customerNameCache = {};
  final Set<String> _selectedOrderIds = {};

  // --- STATE BARU UNTUK FILTER ---
  String? _activeStatusFilter; // null berarti "Semua"
  final List<String> _statusOptions = [
    'pending',
    'processed',
    'completed',
    'cancelled',
  ];

  bool get _isSelectionMode => _selectedOrderIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // Fungsi untuk memuat/me-refresh data dengan filter saat ini
  void _loadOrders() {
    _selectedOrderIds.clear();
    if (mounted) {
      setState(() {
        _ordersFuture = widget.databaseService.getOrders(
          statusFilter: _activeStatusFilter,
        );
      });
    }
  }

  // Fungsi yang dipanggil saat chip filter ditekan
  void _onFilterSelected(String? status) {
    setState(() {
      // Jika menekan chip yang sama lagi, batalkan filter
      if (_activeStatusFilter == status) {
        _activeStatusFilter = null;
      } else {
        _activeStatusFilter = status;
      }
      // Muat ulang data dengan filter baru
      _loadOrders();
    });
  }

  Future<void> _handleRefresh() async {
    _customerNameCache.clear();
    _loadOrders();
  }

  Future<String> _getCustomerName(String userId) async {
    if (_customerNameCache.containsKey(userId))
      return _customerNameCache[userId]!;
    final profile = await widget.databaseService.getProfile(userId);
    final name = profile?.data['name'] ?? 'Customer Dihapus';
    _customerNameCache[userId] = name;
    return name;
  }

  void _changeOrderStatus(String orderId, String newStatus) async {
    try {
      await widget.databaseService.updateOrderStatus(orderId, newStatus);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pesanan berhasil diubah menjadi $newStatus.'),
            backgroundColor: Colors.green,
          ),
        );
      _loadOrders();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah status: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  void _onOrderSelected(String orderId, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        _selectedOrderIds.add(orderId);
      } else {
        _selectedOrderIds.remove(orderId);
      }
    });
  }

  void _performBulkAction(String newStatus) async {
    final idsToUpdate = List<String>.from(_selectedOrderIds);
    try {
      await widget.databaseService.bulkUpdateOrderStatus(
        idsToUpdate,
        newStatus,
      );
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${idsToUpdate.length} pesanan diubah menjadi $newStatus',
            ),
            backgroundColor: Colors.green,
          ),
        );
      _loadOrders();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melakukan aksi massal: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  // <<< FUNGSI BARU UNTUK MEMBUAT TOMBOL TEKS >>>
  Widget _buildTextActionButton(String status, String label, Color color) {
    return TextButton(
      onPressed: () => _performBulkAction(status),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // --- FUNGSI NAVIGASI DETAIL YANG DIPERBAIKI ---
  void _navigateToDetailPage(models.Document order, String customerName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailPage(
          order: order,
          customerName: customerName,
          databaseService: widget.databaseService,
          authService: widget.authService,
        ),
      ),
    );
    if (result == true && mounted) _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bungkus body dengan Column untuk menempatkan filter di atas list
      body: Column(
        children: [
          // --- UI FILTER BARU ---
          _buildFilterChips(),

          // Gunakan Expanded agar ListView mengisi sisa ruang
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
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
                    final filterText = _activeStatusFilter != null
                        ? '"$_activeStatusFilter"'
                        : '';
                    return Center(
                      child: Text(
                        'Tidak ada pesanan $filterText.',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  final orders = snapshot.data!;
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return FutureBuilder<String>(
                        future: _getCustomerName(order.data['customerId']),
                        builder: (context, nameSnapshot) {
                          if (nameSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: SizedBox(
                                height: 130,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          }
                          final customerName =
                              nameSnapshot.data ?? 'Nama Tidak Ditemukan';

                          return OrderCard(
                            order: order,
                            customerName: customerName,
                            onStatusChanged: (newStatus) =>
                                _changeOrderStatus(order.$id, newStatus),
                            onTap: () =>
                                _navigateToDetailPage(order, customerName),
                            isSelected: _selectedOrderIds.contains(order.$id),
                            onSelected: (isSelected) =>
                                _onOrderSelected(order.$id, isSelected),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isSelectionMode ? _buildBulkActionPanel() : null,
    );
  }

  // <<< TAMBAHKAN FUNGSI BARU INI UNTUK MEMBUAT FILTER CHIPS >>>
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

  Widget _buildBulkActionPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white, // Ganti warna latar menjadi putih
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Info dan Tombol Batal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedOrderIds.length} pesanan terpilih',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              // Tombol Batalkan Seleksi
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedOrderIds.clear(); // Kosongkan set pilihan
                  });
                },
                child: const Text(
                  'Batalkan',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ubah status semua pesanan terpilih ke:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          // Baris Tombol Aksi
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTextActionButton(
                  'pending',
                  'Pending',
                  Colors.orange.shade800,
                ),
                const SizedBox(width: 8),
                _buildTextActionButton(
                  'processed',
                  'Diproses',
                  Colors.blue.shade800,
                ),
                const SizedBox(width: 8),
                _buildTextActionButton(
                  'completed',
                  'Selesai',
                  Colors.green.shade800,
                ),
                const SizedBox(width: 8),
                _buildTextActionButton(
                  'cancelled',
                  'Dibatalkan',
                  Colors.red.shade800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
