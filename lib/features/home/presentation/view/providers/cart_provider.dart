import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => List.unmodifiable(_cartItems);

  void addToCart(Map<String, dynamic> shoe) {
    _cartItems.add(shoe);
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> shoe) {
    _cartItems.remove(shoe);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
} 