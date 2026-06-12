import 'package:dio/dio.dart';
import '../api_client.dart';

class TeamQueryHelper {
  final Dio _dio = buildDio();

  Future<List<dynamic>> getAllTeams({int page = 0, int size = 20}) async {
    final response = await _dio.get('/teams', queryParameters: {'page': page, 'size': size});
    return (response.data['content'] as List?) ?? [];
  }

  Future<List<dynamic>> getTeamsByClub(int clubId, {int page = 0, int size = 20}) async {
    final response = await _dio.get('/teams/club/$clubId',
        queryParameters: {'page': page, 'size': size});
    return (response.data['content'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> getTeamById(int id) async {
    final response = await _dio.get('/teams/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> createTeam({
    required String name,
    required String category,
    required String gender,
    int? clubId,
    String? logoUrl,
  }) async {
    final response = await _dio.post('/teams', data: {
      'name': name,
      'category': category,
      'gender': gender,
      'clubId': ?clubId,
      'logoUrl': ?logoUrl,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> updateTeam(int id, {
    String? name,
    String? category,
    String? gender,
    String? logoUrl,
  }) async {
    final response = await _dio.put('/teams/$id', data: {
      'name': ?name,
      'category': ?category,
      'gender': ?gender,
      'logoUrl': ?logoUrl,
    });
    return response.data;
  }

  Future<void> deleteTeam(int id) async {
    await _dio.delete('/teams/$id');
  }

  Future<Map<String, dynamic>> addMember(int teamId, int userId) async {
    final response = await _dio.post('/teams/$teamId/members/$userId');
    return response.data;
  }

  Future<Map<String, dynamic>> removeMember(int teamId, int userId) async {
    final response = await _dio.delete('/teams/$teamId/members/$userId');
    return response.data;
  }

  Future<Map<String, dynamic>> updateMemberRole(
      int teamId, int userId, String role) async {
    final response = await _dio.patch('/teams/$teamId/members/$userId/role',
        data: {'role': role});
    return response.data;
  }
}