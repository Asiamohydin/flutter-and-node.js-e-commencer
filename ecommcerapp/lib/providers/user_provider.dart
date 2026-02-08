import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isAdmin => _user != null && _user!['role'] == 'admin';

  void setUser(Map<String, dynamic> user, String token) {
    _user = user;
    _token = token;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }

  void updateName(String name) {
    if (_user != null) {
      _user!['name'] = name;
      notifyListeners();
    }
  }
}
