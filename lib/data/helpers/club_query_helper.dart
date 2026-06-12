import 'package:dio/dio.dart';
import '../api_client.dart';

class ClubQueryHelper {
  final Dio _dio = buildDio();

  Future<List<dynamic>> getAllClubs({int page = 0, int size = 20}) async {
    final response = await _dio.get('/clubs', queryParameters: {'page': page, 'size': size});
    return (response.data['content'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> getClubById(int id) async {
    final response = await _dio.get('/clubs/$id');
    return response.data;
  }

  Future<List<dynamic>> getClubMembers(int clubId) async {
    final response = await _dio.get('/clubs/$clubId/members');
    return (response.data as List?) ?? [];
  }

  Future<Map<String, dynamic>> createClub({
    required String name,
    required String city,
    String? logoUrl,
    String? description,
    String? websiteUrl,
  }) async {
    final response = await _dio.post('/clubs', data: {
      'name': name,
      'city': city,
      'logoUrl': ?logoUrl,
      'description': ?description,
      'websiteUrl': ?websiteUrl,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> updateClub(int id, {
    String? name,
    String? city,
    String? logoUrl,
    String? description,
    String? websiteUrl,
  }) async {
    final response = await _dio.put('/clubs/$id', data: {
      'name': ?name,
      'city': ?city,
      'logoUrl': ?logoUrl,
      'description': ?description,
      'websiteUrl': ?websiteUrl,
    });
    return response.data;
  }

  Future<void> deleteClub(int id) async {
    await _dio.delete('/clubs/$id');
  }

  Future<Map<String, dynamic>> joinClub(int clubId, int userId) async {
    final response = await _dio.post('/clubs/$clubId/members/$userId');
    return response.data;
  }

  Future<void> leaveClub(int clubId, int userId) async {
    await _dio.delete('/clubs/$clubId/members/$userId');
  }

  Future<Map<String, dynamic>> updateMemberRole(
      int clubId, int userId, String role) async {
    final response = await _dio.patch('/clubs/$clubId/members/$userId/role',
        data: {'role': role});
    return response.data;
  }
}