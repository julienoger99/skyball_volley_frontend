import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _baseUrl = 'http://localhost:8080/api/v1';
const _tokenKey = 'auth_token';

final _storage = FlutterSecureStorage();

Dio buildDio() {
  final dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ));

  return dio;
}

Future<void> saveToken(String token) =>
    _storage.write(key: _tokenKey, value: token);

Future<void> deleteToken() => _storage.delete(key: _tokenKey);