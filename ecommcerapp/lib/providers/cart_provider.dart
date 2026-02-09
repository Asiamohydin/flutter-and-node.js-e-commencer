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

  void addToCart(Product product, {String? color, String? size}) {
    if (product.stock <= 0) return;

    // Unique key considering variants
    final key = "${product.id}_${color ?? ''}_${size ?? ''}";

    if (_items.containsKey(key)) {
      if (_items[key]!.quantity < product.stock) {
        _items[key] = _items[key]!.copyWith(quantity: _items[key]!.quantity + 1);
      }
    } else {
      _items[key] = CartItem(
        product: product, 
        quantity: 1,
        key: key,
        selectedColor: color,
        selectedSize: size,
      );
    }
    notifyListeners();
  }

  void updateQuantity(String itemKey, int change) {
    if (!_items.containsKey(itemKey)) return;

    final current = _items[itemKey]!;
    final newQty = current.quantity + change;

    if (newQty <= 0) {
      _items.remove(itemKey);
    } else {
      _items[itemKey] = current.copyWith(quantity: newQty);
    }
    notifyListeners();
  }

  void removeItem(String itemKey) {
    _items.remove(itemKey);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
