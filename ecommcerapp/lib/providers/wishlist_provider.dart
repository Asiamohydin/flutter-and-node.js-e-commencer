import 'package:flutter/material.dart';
import 'package:ecommcerapp/models/product.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  void toggleWishlist(Product product) {
    final isExist = _items.any((item) => item.id == product.id);
    if (isExist) {
      _items.removeWhere((item) => item.id == product.id);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }

  bool isExist(Product product) {
    return _items.any((item) => item.id == product.id);
  }

  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }
}
