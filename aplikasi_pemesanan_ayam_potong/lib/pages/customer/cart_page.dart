// lib/pages/customer/cart_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/appwrite.dart';
import '../../providers/cart_provider.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/cart_item.dart';

class CartPage extends StatefulWidget {
  final AuthService authService;
  final DatabaseService databaseService;

  const CartPage({
    Key? key,
    required this.authService,
    required this.databaseService,
  }) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Hanya butuh controller untuk deskripsi
  final _descriptionController = TextEditingController();
  bool _isProcessing = false;

  void _checkout() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final user = await widget.authService.getCurrentUser();

    if (user == null) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesi Anda telah berakhir.')));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Panggil fungsi checkout yang sudah disederhanakan
      await widget.databaseService.createOrderFromCart(
        userId: user.$id,
        cartItems: cart.items.values.toList(),
        totalPrice: cart.totalAmount,
        description: _descriptionController.text.trim(),
      );

      cart.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat!'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } on AppwriteException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat pesanan: ${e.message}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (ctx, cart, _) {
        final cartItems = cart.items.values.toList();
        final cartItemKeys = cart.items.keys.toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Checkout Pesanan')),
          body: Column(
            children: [
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text('Keranjang Anda masih kosong.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: cartItems.length,
                        itemBuilder: (ctx, i) {
                          return CartItemTile(
                            cartItemKey: cartItemKeys[i],
                            item: cartItems[i],
                          );
                        },
                      ),
              ),

              // Bagian Form & Tombol Checkout
              Card(
                margin: EdgeInsets.zero,
                elevation: 10,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // HANYA ADA FORM DESKRIPSI
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Tambahan (Opsional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const Divider(height: 24),
                      // Ringkasan Total & Tombol Checkout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Bayar', style: TextStyle(color: Colors.grey)),
                              Text(
                                'Rp ${cart.totalAmount.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                            onPressed: (cart.items.isEmpty || _isProcessing) ? null : _checkout,
                            child: _isProcessing 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                                : const Text('PESAN SEKARANG'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget CartItemTile sekarang menampilkan info potongan
class CartItemTile extends StatelessWidget {
  final String cartItemKey;
  final CartItem item;

  const CartItemTile({Key? key, required this.cartItemKey, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColorLight,
            child: Text('x${item.quantity}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark)),
          ),
          title: Text(item.name),
          // TAMPILKAN INFORMASI POTONGAN DI SINI
          subtitle: Text('Potong ${item.pieces}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => cart.removeSingleItem(cartItemKey)),
              Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.green), onPressed: () => cart.addSingleItem(cartItemKey)),
            ],
          ),
        ),
      ),
    );
  }
}