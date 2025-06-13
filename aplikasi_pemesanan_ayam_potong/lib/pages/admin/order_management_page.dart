// lib/pages/admin/order_management_page.dart

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;
import '../../services/database_service.dart';

class OrderManagementPage extends StatefulWidget {
  final DatabaseService databaseService;
  const OrderManagementPage({Key? key, required this.databaseService}) : super(key: key);

  @override
  _OrderManagementPageState createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  late Future<List<models.Document>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = widget.databaseService.getOrders();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'processed': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<models.Document>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada pesanan masuk.'));
        }

        final orders = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => _refreshOrders(),
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderData = order.data;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Order ID: ${order.$id.substring(0, 8)}...'),
                  subtitle: Text('Total: Rp ${orderData['totalPrice']}'),
                  trailing: DropdownButton<String>(
                    value: orderData['status'],
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        await widget.databaseService.updateOrderStatus(order.$id, newValue);
                        _refreshOrders();
                      }
                    },
                    items: <String>['pending', 'processed', 'completed', 'cancelled']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value.toUpperCase(),
                          style: TextStyle(color: _getStatusColor(value)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}