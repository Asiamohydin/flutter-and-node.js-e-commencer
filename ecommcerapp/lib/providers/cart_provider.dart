import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {}; // key = product.id

  Map<String, CartItem> get items => {..._items};

  List<CartItem> get itemsList => _items.values.toList();

  double get totalAmount {
    double total = 0;
    for (final item in _items.values) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  void addToCart(Product product) {
    final id = product.id;

    if (_items.containsKey(id)) {
      _items[id] = _items[id]!.copyWith(quantity: _items[id]!.quantity + 1);
    } else {
      _items[id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int change) {
    if (!_items.containsKey(productId)) return;

    final current = _items[productId]!;
    final newQty = current.quantity + change;

    if (newQty <= 0) {
      _items.remove(productId);
    } else {
      _items[productId] = current.copyWith(quantity: newQty);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
