import 'package:dio/dio.dart';
import '../api_client.dart';

class AuthQueryHelper {
  final Dio _dio = buildDio();

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    final token = response.data['token'] as String;
    await saveToken(token);
    return response.data;
  }

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final response = await _dio.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
    await deleteToken();
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _dio.post('/auth/forgot-password', data: {'email': email});
    return response.data;
  }

  Future<Map<String, dynamic>> resetPassword(
      String token, String newPassword) async {
    final response = await _dio.post('/auth/reset-password', data: {
      'token': token,
      'newPassword': newPassword,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> resendVerification(String email) async {
    final response = await _dio.post('/auth/resend-verification', data: {'email': email});
    return response.data;
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    final response = await _dio.get('/auth/verify', queryParameters: {'token': token});
    return response.data;
  }
}