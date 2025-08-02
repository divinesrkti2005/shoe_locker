import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRemoteDataSource {
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, 
          'password': password
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'token': data['token'],
          'user': data['data'],
          'success': true,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> register(String fname, String lname, String email, String password, String phone) async {
    try {
      final requestBody = {
        'fname': fname,
        'lname': lname,
        'email': email, 
        'password': password,
        'phone': phone,
      };
      print('Register request body: $requestBody'); // Debug print
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>?> getCustomerProfile(String token, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/getCustomer/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        return null;
      }
    } catch (e) {
      print('Get profile exception: $e');
      return null;
    }
  }
}