import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:shoe_locker/features/auth/data/data_source/auth_remote_datasource.dart';

class TestableAuthRemoteDataSource extends AuthRemoteDataSource {
  final http.Client client;
  TestableAuthRemoteDataSource(this.client);
  @override
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse(' [AuthRemoteDataSource.baseUrl]/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
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
}

void main() {
  test('login returns token and user on success', () async {
    final dataSource = TestableAuthRemoteDataSource(MockClient((request) async {
      return http.Response(jsonEncode({'token': 'abc', 'data': {'_id': '1', 'role': 'customer'}}), 200);
    }));
    final result = await dataSource.login('test@test.com', 'password');
    expect(result?['token'], 'abc');
    expect(result?['user']['_id'], '1');
  });
} 