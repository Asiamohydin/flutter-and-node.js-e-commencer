import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];
  final ApiService _api = ApiService();

  List<Order> get orders => List.unmodifiable(_orders);

  void addLocalOrder(
    Map<String, CartItem> cartItems,
    double totalAmount, {
    required String paymentMethod,
    required Map<String, dynamic> paymentInfo,
  }) {
    final itemsList = cartItems.entries.map((entry) {
      final item = entry.value;
      final p = item.product;

      return {
        "productId": p.id,
        // Product model uses `name`
        "title": p.name,
        "price": p.price,
        "quantity": item.quantity,
        "imageUrl": p.imageUrl,
      };
    }).toList();

    _orders.insert(
      0,
      Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: itemsList,
        total: totalAmount,
        createdAt: DateTime.now(),
        paymentMethod: paymentMethod,
        paymentInfo: paymentInfo,
      ),
    );

    notifyListeners();
  }

  String? _lastError;
  String? get lastError => _lastError;

  Future<bool> placeOrder(Map<String, CartItem> cartItems, double totalAmount, {required String paymentMethod, required Map<String, dynamic> paymentInfo}) async {
    _lastError = null;
    final itemsList = cartItems.entries.map((entry) {
      final item = entry.value;
      final p = item.product;
      return {
        "productId": p.id,
        "title": p.name,
        "price": p.price,
        "quantity": item.quantity,
        "imageUrl": p.imageUrl,
        "selectedColor": item.selectedColor,
        "selectedSize": item.selectedSize,
      };
    }).toList();

    final resp = await _api.placeOrder(itemsList, totalAmount, paymentMethod, paymentInfo);
    if (resp['status'] == 201) {
      final body = resp['body'];
      // Convert API order to local Order model
      final order = Order(
        id: body['id'].toString(),
        items: List<Map<String, dynamic>>.from(body['items'] ?? []),
        total: double.tryParse(body['total'].toString()) ?? 0.0,
        createdAt: DateTime.tryParse(body['created_at'] ?? '') ?? DateTime.now(),
        paymentMethod: body['payment_method'] ?? paymentMethod,
        paymentInfo: {},
        status: body['status'] ?? 'pending',
      );
      _orders.insert(0, order);
      notifyListeners();
      return true;
    } else {
      _lastError = resp['error'] ?? resp['body']?['message'] ?? 'Unknown order error';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchOrders() async {
    final resp = await _api.getOrders();
    if (resp['status'] == 200) {
      final list = resp['body'] as List<dynamic>;
      _orders.clear();
      for (final item in list) {
        _orders.add(Order(
          id: item['id'].toString(),
          items: List<Map<String, dynamic>>.from(item['items'] ?? []),
          total: double.tryParse(item['total'].toString()) ?? 0.0,
          createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
          paymentMethod: item['payment_method'] ?? '',
          paymentInfo: {},
          status: item['status'] ?? 'pending',
        ));
      }
      notifyListeners();
    }
  }
}
