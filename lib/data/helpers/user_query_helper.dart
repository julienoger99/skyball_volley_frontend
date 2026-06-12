import 'package:dio/dio.dart';
import '../api_client.dart';

class UserQueryHelper {
  final Dio _dio = buildDio();

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get('/users/me');
    return response.data;
  }

  Future<List<dynamic>> getAllUsers() async {
    final response = await _dio.get('/users');
    return response.data;
  }

  Future<Map<String, dynamic>> getUserById(int id) async {
    final response = await _dio.get('/users/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> updateUser(int id, {String? username, String? email}) async {
    final response = await _dio.put('/users/$id', data: {
      'username': ?username,
      'email': ?email,
    });
    return response.data;
  }

  Future<void> deleteUser(int id) async {
    await _dio.delete('/users/$id');
  }
}