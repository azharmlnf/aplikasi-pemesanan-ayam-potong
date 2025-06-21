// lib/pages/customer/cart_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart'; // <--- TAMBAHKAN BARIS INI

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer di level tertinggi agar seluruh halaman di-rebuild
    // saat ada perubahan signifikan di keranjang.
    return Consumer<CartProvider>(
      builder: (ctx, cart, _) {
        final cartItems = cart.items.values.toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Keranjang Saya'),
          ),
          body: Column(
            children: [
              // Ringkasan Total Harga
              Card(
                margin: const EdgeInsets.all(15),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text('Total', style: TextStyle(fontSize: 20)),
                      const Spacer(),
                      Chip(
                        label: Text(
                          'Rp ${cart.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryTextTheme.titleLarge?.color,
                          ),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      TextButton(
                        child: const Text('PESAN SEKARANG'),
                        onPressed: cart.items.isEmpty ? null : () {
                          // TODO: Implementasi logika checkout
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur checkout belum diimplementasikan.'))
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Daftar Item di Keranjang
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text('Keranjang Anda masih kosong.'))
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (ctx, i) => CartItemTile(
                          item: cartItems[i],
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

// Widget terpisah untuk setiap baris item di keranjang
class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Dismissible(
      key: ValueKey(item.productId),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(Icons.delete, color: Colors.white, size: 40),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        cart.removeItem(item.productId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: FittedBox(child: Text('Rp${item.price.toStringAsFixed(0)}')),
              ),
            ),
            title: Text(item.name),
            subtitle: Text('Total: Rp${(item.price * item.quantity).toStringAsFixed(0)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => cart.removeSingleItem(item.productId),
                ),
                Text('${item.quantity}x'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => cart.addItem(item),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}