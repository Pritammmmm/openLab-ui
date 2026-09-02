import '../../../core/network/dio_client.dart';

class HealthApi {
  final DioClient _client;

  HealthApi(this._client);

  Future<Map<String, dynamic>> syncMetrics(
    List<Map<String, dynamic>> metrics,
  ) async {
    final response = await _client.post(
      '/health/metrics/sync',
      data: {'metrics': metrics},
    );
    return response.data;
  }

  Future<List<dynamic>> getMetrics({
    required String profileId,
    String? type,
    String? from,
    String? to,
    int? limit,
  }) async {
    final params = <String, dynamic>{'profile_id': profileId};
    if (type != null) params['type'] = type;
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    if (limit != null) params['limit'] = limit;

    final response = await _client.get(
      '/health/metrics',
      queryParameters: params,
    );
    return response.data['data'] ?? [];
  }

  Future<void> deleteMetric(String id) async {
    await _client.delete('/health/metrics/$id');
  }

  Future<Map<String, dynamic>> syncDailyLogs(
    List<Map<String, dynamic>> logs,
  ) async {
    final response = await _client.post(
      '/health/daily-logs/sync',
      data: {'logs': logs},
    );
    return response.data;
  }

  Future<List<dynamic>> getDailyLogs({
    required String profileId,
    String? from,
    String? to,
  }) async {
    final params = <String, dynamic>{'profile_id': profileId};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;

    final response = await _client.get(
      '/health/daily-logs',
      queryParameters: params,
    );
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> syncFoodEntries(
    List<Map<String, dynamic>> entries,
  ) async {
    final response = await _client.post(
      '/health/food-entries/sync',
      data: {'entries': entries},
    );
    return response.data;
  }

  Future<List<dynamic>> getInsights(String profileId) async {
    final response = await _client.get(
      '/health/insights',
      queryParameters: {'profile_id': profileId},
    );
    return response.data['data'] ?? [];
  }
}
