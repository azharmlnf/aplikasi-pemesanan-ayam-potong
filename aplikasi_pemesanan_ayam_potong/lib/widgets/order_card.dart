// lib/widgets/order_card.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;

class OrderCard extends StatelessWidget {
  final models.Document order;
  final String customerName;
  final Function(String newStatus) onStatusChanged;

  const OrderCard({
    Key? key,
    required this.order,
    required this.customerName,
    required this.onStatusChanged,
  }) : super(key: key);

  // Fungsi pembantu untuk warna status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange.shade700;
      case 'processed': return Colors.blue.shade700;
      case 'completed': return Colors.green.shade700;
      case 'cancelled': return Colors.red.shade700;
      default: return Colors.grey.shade700;
    }
  }

  // Fungsi pembantu untuk format tanggal
  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final orderData = order.data;
    final status = orderData['status'] ?? 'pending';

    // --- BUAT LIST OF DROPDOWN ITEMS DI SINI ---
    final List<DropdownMenuItem<String>> dropdownItems = 
        ['pending', 'processed', 'completed', 'cancelled']
            .map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          value.toUpperCase(),
          // Panggil _getStatusColor di sini, di mana ia pasti dikenali
          style: TextStyle(
            color: _getStatusColor(value), 
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }).toList();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    customerName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownButton<String>(
                  value: status,
                  underline: Container(),
                  // Gunakan variabel yang sudah kita buat
                  items: dropdownItems, 
                  onChanged: (String? newValue) {
                    if (newValue != null && newValue != status) {
                      onStatusChanged(newValue);
                    }
                  },
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: #${order.$id.substring(0, 8)}...'),
                      const SizedBox(height: 4),
                      Text('Tanggal: ${_formatDate(order.$createdAt)}'),
                    ],
                  ),
                ),
                Text(
                  'Rp ${orderData['totalPrice']?.toStringAsFixed(0) ?? '0'}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}