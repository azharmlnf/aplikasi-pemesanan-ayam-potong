// lib/pages/customer/cart_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (ctx, cart, _) {
        final cartItems = cart.items.values.toList();
        final cartItemKeys = cart.items.keys.toList(); // Ambil juga list of keys

        return Scaffold(
          appBar: AppBar(title: const Text('Keranjang Saya')),
          body: Column(
            children: [
              // Pesan Peringatan
              if (cartItems.isNotEmpty) // Tampilkan hanya jika ada item
                Container(
                  width: double.infinity,
                  color: Colors.amber.shade100,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade800),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Item di keranjang akan terhapus jika Anda keluar dari aplikasi.',
                          style: TextStyle(color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              
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
                        },
                      )
                    ],
                  ),
                ),
              ),

              // Daftar Item di Keranjang
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text('Keranjang Anda masih kosong.'))
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (ctx, i) {
                          // --- INI BAGIAN YANG DIPERBAIKI ---
                          // Kirim key dan item ke widget tile
                          return CartItemTile(
                            cartItemKey: cartItemKeys[i],
                            item: cartItems[i],
                          );
                        },
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
  final String cartItemKey;
  final CartItem item;

  const CartItemTile({
    Key? key,
    required this.cartItemKey,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Dismissible(
      key: ValueKey(cartItemKey),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 40),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => cart.removeItem(cartItemKey),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColorLight,
              child: FittedBox(
                child: Text('x${item.quantity}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark)),
              ),
            ),
            title: Text(item.name),
            subtitle: Text('Potong ${item.pieces} - Rp${item.price.toStringAsFixed(0)}/pcs'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => cart.removeSingleItem(cartItemKey),
                ),
                Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
               onPressed: () => cart.addSingleItem(cartItemKey), 
                tooltip: 'Tambah Jumlah',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}