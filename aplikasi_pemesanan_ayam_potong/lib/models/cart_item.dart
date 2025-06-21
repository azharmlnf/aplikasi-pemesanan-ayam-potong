// lib/models/cart_item.dart

import 'package:appwrite/models.dart' as models;

class CartItem {
  final String productId;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  factory CartItem.fromProduct(models.Document productDoc) {
    return CartItem(
      productId: productDoc.$id,
      name: productDoc.data['name'] ?? 'Tanpa Nama',
      price: (productDoc.data['price'] ?? 0.0).toDouble(),
    );
  }
}