// lib/providers/cart_provider.dart

import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  // Hanya ada satu properti: daftar item.
  Map<String, CartItem> _items = {};

  // --- CONSTRUCTOR YANG BENAR (TIDAK ADA ARGUMEN) ---
  // Hapus constructor lama jika ada. Jika tidak ada constructor sama sekali,
  // Dart akan secara otomatis menggunakan constructor kosong seperti ini.
  // Jadi, Anda bisa membiarkannya kosong.

  // Getter untuk mengakses data dari luar
  Map<String, CartItem> get items => {..._items};

  // Getter untuk mendapatkan jumlah total item (memperhitungkan kuantitas)
  int get itemCount {
    int totalItems = 0;
    _items.forEach((key, cartItem) {
      totalItems += cartItem.quantity;
    });
    return totalItems;
  }

  // Getter untuk menghitung total harga
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Fungsi untuk MENAMBAH item ke keranjang
  void addItem(CartItem item) {
    if (_items.containsKey(item.productId)) {
      _items.update(
        item.productId,
        (existingCartItem) => CartItem(
          productId: existingCartItem.productId,
          name: existingCartItem.name,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        item.productId,
        () => CartItem(
          productId: item.productId,
          name: item.name,
          price: item.price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  // Fungsi untuk MENGURANGI kuantitas atau menghapus item
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
            productId: existing.productId,
            name: existing.name,
            price: existing.price,
            quantity: existing.quantity - 1),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }
  
  // Fungsi untuk MENGHAPUS item sepenuhnya dari keranjang
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Fungsi untuk MEMBERSIHKAN keranjang (saat logout)
  void clear() {
    _items = {};
    notifyListeners();
  }
}