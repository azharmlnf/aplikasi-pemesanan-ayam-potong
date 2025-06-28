// lib/widgets/order_card.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;

class OrderCard extends StatelessWidget {
  final models.Document order;
  final String customerName;
  final Function(String newStatus)? onStatusChanged;
  final bool isSelected;
  final ValueChanged<bool?>? onSelected;
  final VoidCallback? onTap; // Callback untuk navigasi detail
  final VoidCallback? onLongPress;

  const OrderCard({
    Key? key,
    required this.order,
    required this.customerName,
    this.onStatusChanged,
    this.isSelected = false,
    this.onSelected,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange.shade700;
      case 'processed':
        return Colors.blue.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

@override
  Widget build(BuildContext context) {
    final orderData = order.data;
    final status = orderData['status'] ?? 'pending';
    
    final bool canChangeStatus = onStatusChanged != null;
    // 'isSelectionMode' sekarang kita definisikan berdasarkan apakah ada item yang sudah terpilih
    // Ini lebih baik kita terima dari parent. Kita tetap gunakan 'onSelected != null'.
    final bool canSelect = onSelected != null;

    return Card(
      color: isSelected ? Colors.teal.shade50 : null,
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
         onTap: onTap,
        onLongPress: onLongPress,
        
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tampilkan ikon placeholder/check HANYA jika bisa diseleksi
              if (canSelect)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 20),
                  child: isSelected
                      ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                      : Icon(Icons.circle_outlined, color: Colors.grey.shade400),
                ),
              
              // Konten Kartu
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            customerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (canChangeStatus)
                          DropdownButton<String>(
                            value: status,
                            underline: Container(),
                            items:
                                [
                                      'pending',
                                      'processed',
                                      'completed',
                                      'cancelled',
                                    ]
                                    .map(
                                      (String value) =>
                                          DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value.toUpperCase(),
                                              style: TextStyle(
                                                color: _getStatusColor(value),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                    )
                                    .toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null && newValue != status) {
                                onStatusChanged!(newValue);
                              }
                            },
                          )
                        else
                          Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: _getStatusColor(status),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
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
                              Text(
                                'Order ID: #${order.$id.substring(0, 8)}...',
                              ),
                              const SizedBox(height: 4),
                              Text('Tanggal: ${_formatDate(order.$createdAt)}'),
                            ],
                          ),
                        ),
                        Text(
                          'Rp ${orderData['totalPrice']?.toStringAsFixed(0) ?? '0'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
