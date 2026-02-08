import 'package:flutter/material.dart';

class PaymentCard {
  final String id;
  final String brand;
  final String number;
  final String expiry;
  final String holder;
  final Color color;

  PaymentCard({
    required this.id,
    required this.brand,
    required this.number,
    required this.expiry,
    required this.holder,
    required this.color,
  });
}

class PaymentProvider extends ChangeNotifier {
  final List<PaymentCard> _cards = [
    PaymentCard(
      id: '1',
      brand: 'Visa',
      number: '**** **** **** 4242',
      expiry: '12/26',
      holder: 'JOHN DOE',
      color: Colors.blue,
    ),
    PaymentCard(
      id: '2',
      brand: 'Mastercard',
      number: '**** **** **** 5555',
      expiry: '09/25',
      holder: 'JOHN DOE',
      color: Colors.orange,
    ),
  ];

  List<PaymentCard> get cards => List.unmodifiable(_cards);

  void addCard(PaymentCard card) {
    _cards.add(card);
    notifyListeners();
  }

  void removeCard(String id) {
    _cards.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
