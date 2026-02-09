import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommcerapp/models/product.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();
  final _base = 'http://localhost:5000/api';

  Future<String?> _token() async => await _storage.read(key: 'jwt');

  Future<List<Product>> getProducts() async {
    try {
      final token = await _token();
      final resp = await http.get(Uri.parse('$_base/products'), headers: token != null ? {'Authorization': 'Bearer $token'} : null);
      if (resp.statusCode == 200) {
        List<dynamic> data = json.decode(resp.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${resp.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      final data = json.decode(response.body);
      if (data['success'] == true && data['token'] != null) {
        await _storage.write(key: 'jwt', value: data['token']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );
      final data = json.decode(response.body);
      if (data['success'] == true && data['token'] != null) {
        await _storage.write(key: 'jwt', value: data['token']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
  }

  Future<Map<String, dynamic>> placeOrder(List<Map<String, dynamic>> items, double total, String paymentMethod, Map<String, dynamic> paymentInfo) async {
    try {
      final token = await _token();
      final resp = await http.post(Uri.parse('$_base/orders'),
        headers: {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'},
        body: json.encode({'items': items, 'total': total, 'paymentMethod': paymentMethod, 'paymentInfo': paymentInfo}),
      );
      final data = json.decode(resp.body);
      return {'status': resp.statusCode, 'body': data};
    } catch (e) {
      return {'status': 500, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getOrders() async {
    try {
      final token = await _token();
      final resp = await http.get(Uri.parse('$_base/orders'), headers: token != null ? {'Authorization': 'Bearer $token'} : null);
      final data = json.decode(resp.body);
      return {'status': resp.statusCode, 'body': data};
    } catch (e) {
      return {'status': 500, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProfile(String name, {String? password, String? imageUrl}) async {
    try {
      final token = await _token();
      final body = {'name': name};
      if (password != null && password.isNotEmpty) body['password'] = password;
      if (imageUrl != null && imageUrl.isNotEmpty) body['image_url'] = imageUrl;

      final resp = await http.put(Uri.parse('$_base/auth/update-me'),
        headers: {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'},
        body: json.encode(body),
      );
      return json.decode(resp.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final token = await _token();
      final resp = await http.get(Uri.parse('$_base/orders/stats'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200) {
        return json.decode(resp.body);
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(int orderId, String status) async {
    try {
      final token = await _token();
      final resp = await http.put(Uri.parse('$_base/orders/$orderId'),
        headers: {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'},
        body: json.encode({'status': status}),
      );
      
      if (resp.headers['content-type']?.contains('application/json') ?? false) {
        return json.decode(resp.body);
      } else {
        return {'success': false, 'message': 'Server error: ${resp.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> product) async {
    try {
      final token = await _token();
      final resp = await http.post(Uri.parse('$_base/products'),
        headers: {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'},
        body: json.encode(product),
      );
      return json.decode(resp.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> product) async {
    try {
      final token = await _token();
      final resp = await http.put(Uri.parse('$_base/products/$id'),
        headers: {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'},
        body: json.encode(product),
      );
      return json.decode(resp.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final token = await _token();
      final resp = await http.delete(Uri.parse('$_base/products/$id'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      return json.decode(resp.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> uploadImage(List<int> bytes, String filename) async {
    try {
      final token = await _token();
      final request = http.MultipartRequest('POST', Uri.parse('$_base/upload'));
      
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: filename,
      ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

