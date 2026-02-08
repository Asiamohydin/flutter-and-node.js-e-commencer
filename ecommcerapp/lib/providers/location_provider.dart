import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  String _address = "New York, USA";
  
  String get address => _address;

  void setAddress(String newAddress) {
    _address = newAddress;
    notifyListeners();
  }
}
