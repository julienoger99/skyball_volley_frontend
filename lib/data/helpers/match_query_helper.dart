import 'package:dio/dio.dart';
import '../api_client.dart';

class MatchQueryHelper {
  final Dio _dio = buildDio();

  Future<List<dynamic>> getMatchesByTeam(int teamId,
      {int page = 0, int size = 20}) async {
    final response = await _dio.get('/teams/$teamId/matches',
        queryParameters: {'page': page, 'size': size});
    return (response.data['content'] as List?) ?? [];
  }

  Future<List<dynamic>> getMatchesByChampionship(int championshipId,
      {int page = 0, int size = 20}) async {
    final response = await _dio.get('/championships/$championshipId/matches',
        queryParameters: {'page': page, 'size': size});
    return (response.data['content'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> getMatchById(int id) async {
    final response = await _dio.get('/matches/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> createMatch(int teamId, {
    required String matchDate,
    int? opponentTeamId,
    String? opponentName,
    String? location,
    bool? home,
    int? championshipId,
    String? coachMessage,
  }) async {
    final response = await _dio.post('/teams/$teamId/matches', data: {
      'matchDate': matchDate,
      'opponentTeamId': ?opponentTeamId,
      'opponentName': ?opponentName,
      'location': ?location,
      'home': ?home,
      'championshipId': ?championshipId,
      'coachMessage': ?coachMessage,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> updateMatch(int id, {
    String? matchDate,
    String? location,
    bool? home,
    int? championshipId,
    String? status,
    String? forfeitedBy,
    String? coachMessage,
  }) async {
    final response = await _dio.put('/matches/$id', data: {
      'matchDate': ?matchDate,
      'location': ?location,
      'home': ?home,
      'championshipId': ?championshipId,
      'status': ?status,
      'forfeitedBy': ?forfeitedBy,
      'coachMessage': ?coachMessage,
    });
    return response.data;
  }

  Future<void> deleteMatch(int id) async {
    await _dio.delete('/matches/$id');
  }

  Future<Map<String, dynamic>> addOrUpdateSet(int matchId, {
    required int setNumber,
    required int teamPoints,
    required int opponentPoints,
  }) async {
    final response = await _dio.put('/matches/$matchId/sets', data: {
      'setNumber': setNumber,
      'teamPoints': teamPoints,
      'opponentPoints': opponentPoints,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> setAllSets(
      int matchId, List<Map<String, dynamic>> sets) async {
    final response = await _dio.put('/matches/$matchId/sets/bulk',
        data: {'sets': sets});
    return response.data;
  }

  Future<void> deleteSet(int matchId, int setNumber) async {
    await _dio.delete('/matches/$matchId/sets/$setNumber');
  }

  Future<Map<String, dynamic>> updateAttendance(
      int matchId, int userId, String attendanceStatus) async {
    final response = await _dio.put(
        '/matches/$matchId/players/$userId/attendance',
        data: {'attendanceStatus': attendanceStatus});
    return response.data;
  }

  Future<Map<String, dynamic>> setCaptain(int matchId, int userId) async {
    final response = await _dio.put('/matches/$matchId/captain/$userId');
    return response.data;
  }
}