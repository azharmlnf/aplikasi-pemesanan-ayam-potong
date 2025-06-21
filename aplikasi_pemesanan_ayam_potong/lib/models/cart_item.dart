// lib/models/cart_item.dart

import 'package:appwrite/models.dart' as models;

class CartItem {
  final String productId;
  final String name;
  final double price;
  int quantity;
  final int pieces; // <-- ATRIBUT BARU

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.pieces, // <-- ATRIBUT BARU
  });

  // Fungsi ini tidak lagi digunakan secara langsung, tapi bisa disimpan
  factory CartItem.fromProduct(models.Document productDoc) {
    return CartItem(
      productId: productDoc.$id,
      name: productDoc.data['name'] ?? 'Tanpa Nama',
      price: (productDoc.data['price'] ?? 0.0).toDouble(),
      quantity: 1,
      pieces: 4, // Default value
    );
  }
}