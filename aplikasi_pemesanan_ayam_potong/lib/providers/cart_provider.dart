// lib/providers/cart_provider.dart

import 'package:flutter/foundation.dart';
import 'package:appwrite/models.dart' as models;
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  // Key sekarang akan menjadi kombinasi productId-pieces agar unik
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get totalItemCount {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // --- FUNGSI addItem YANG BARU ---
  void addItem({
    required models.Document productDoc,
    required int quantity,
    required int pieces,
  }) {
    final productId = productDoc.$id;
    // Buat key yang unik: "idProduk-jumlahPotongan"
    // Contoh: "ayam-broiler-123-8"
    final cartItemKey = '$productId-$pieces';

    if (_items.containsKey(cartItemKey)) {
      // Jika item dengan produk & potongan yang sama sudah ada, update kuantitasnya
      _items.update(
        cartItemKey,
        (existingItem) => CartItem(
          productId: existingItem.productId,
          name: existingItem.name,
          price: existingItem.price,
          quantity: existingItem.quantity + quantity, // Tambah dengan kuantitas baru
          pieces: existingItem.pieces,
        ),
      );
    } else {
      // Jika belum ada, tambahkan sebagai item baru
      _items.putIfAbsent(
        cartItemKey,
        () => CartItem(
          productId: productId,
          name: productDoc.data['name'] ?? 'Tanpa Nama',
          price: (productDoc.data['price'] ?? 0.0).toDouble(),
          quantity: quantity,
          pieces: pieces,
        ),
      );
    }
    notifyListeners();
  }
  // menambah kuantitas
  void addSingleItem(String cartItemKey) {
    // Pastikan item ada di keranjang
    if (!_items.containsKey(cartItemKey)) return;

    // Update kuantitasnya dengan menambah 1
    _items.update(
      cartItemKey,
      (existingItem) => CartItem(
        productId: existingItem.productId,
        name: existingItem.name,
        price: existingItem.price,
        quantity: existingItem.quantity + 1, // Logika utama
        pieces: existingItem.pieces,
      ),
    );
    notifyListeners();
  }

  // Fungsi untuk MENGURANGI kuantitas (tidak banyak berubah)
  void removeSingleItem(String cartItemKey) {
    if (!_items.containsKey(cartItemKey)) return;

    if (_items[cartItemKey]!.quantity > 1) {
      _items.update(
        cartItemKey,
        (existing) => CartItem(
            productId: existing.productId,
            name: existing.name,
            price: existing.price,
            quantity: existing.quantity - 1,
            pieces: existing.pieces),
      );
    } else {
      _items.remove(cartItemKey);
    }
    notifyListeners();
  }
  
  // Fungsi untuk MENGHAPUS item sepenuhnya dari keranjang
  void removeItem(String cartItemKey) {
    _items.remove(cartItemKey);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}