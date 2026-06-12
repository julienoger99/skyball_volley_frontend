import 'package:dio/dio.dart';
import '../api_client.dart';

class ChampionshipQueryHelper {
  final Dio _dio = buildDio();

  Future<List<dynamic>> getAllChampionships({int page = 0, int size = 20}) async {
    final response = await _dio.get('/championships',
        queryParameters: {'page': page, 'size': size});
    return (response.data['content'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> getChampionshipById(int id) async {
    final response = await _dio.get('/championships/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> createChampionship({
    required String name,
    required String season,
    String? category,
  }) async {
    final response = await _dio.post('/championships', data: {
      'name': name,
      'season': season,
      'category': ?category,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> updateChampionship(int id, {
    String? name,
    String? season,
    String? category,
  }) async {
    final response = await _dio.put('/championships/$id', data: {
      'name': ?name,
      'season': ?season,
      'category': ?category,
    });
    return response.data;
  }

  Future<void> deleteChampionship(int id) async {
    await _dio.delete('/championships/$id');
  }
}