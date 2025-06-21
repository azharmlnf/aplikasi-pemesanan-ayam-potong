// lib/widgets/cart_badge.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({
    Key? key,
    required this.child, // Widget ikon keranjang
    required this.onTap, // Aksi saat ikon ditekan
  }) : super(key: key);

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer agar widget ini saja yang di-rebuild saat keranjang berubah
    return Consumer<CartProvider>(
      builder: (ctx, cart, ch) => InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ch!, // Ini adalah ikon keranjang yang kita kirim
            if (cart.itemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.red,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${cart.itemCount}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
      child: child, // child ini tidak akan di-rebuild, lebih efisien
    );
  }
}