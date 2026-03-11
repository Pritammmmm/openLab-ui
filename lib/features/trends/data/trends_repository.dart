import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

class TrendDataPoint {
  final DateTime date;
  final double value;
  final String status;

  const TrendDataPoint({
    required this.date,
    required this.value,
    required this.status,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
      status: json['status'] as String? ?? json['trafficLight'] as String? ?? 'normal',
    );
  }
}

class TrendParameter {
  final String name;
  final String? category;
  final String unit;
  final double? refMin;
  final double? refMax;
  final List<TrendDataPoint> dataPoints;

  const TrendParameter({
    required this.name,
    this.category,
    required this.unit,
    this.refMin,
    this.refMax,
    required this.dataPoints,
  });

  factory TrendParameter.fromJson(Map<String, dynamic> json) {
    return TrendParameter(
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
      unit: json['unit'] as String? ?? '',
      refMin: (json['refMin'] as num?)?.toDouble(),
      refMax: (json['refMax'] as num?)?.toDouble(),
      dataPoints: (json['dataPoints'] as List<dynamic>?)
              ?.map((e) => TrendDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TrendsRepository {
  final DioClient _client;

  TrendsRepository(this._client);

  Future<List<TrendParameter>> getTrends(
    String profileId, {
    String? parameterName,
    String? category,
  }) async {
    if (parameterName == null) return [];

    final queryParams = <String, dynamic>{
      'parameter_name': parameterName,
    };

    final response = await _client.get(
      ApiEndpoints.trends(profileId),
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    if (data['success'] == true && data['data'] != null) {
      final trendData = data['data'] as Map<String, dynamic>;
      final dataPoints = (trendData['data'] as List<dynamic>?) ?? [];
      final firstPoint = dataPoints.isNotEmpty
          ? dataPoints.first as Map<String, dynamic>
          : null;
      final param = TrendParameter(
        name: trendData['parameterName'] as String? ?? parameterName,
        category: category,
        unit: firstPoint?['unit'] as String? ?? '',
        refMin: (firstPoint?['refRange'] as Map<String, dynamic>?)?['min'] != null
            ? ((firstPoint!['refRange'] as Map<String, dynamic>)['min'] as num).toDouble()
            : null,
        refMax: (firstPoint?['refRange'] as Map<String, dynamic>?)?['max'] != null
            ? ((firstPoint!['refRange'] as Map<String, dynamic>)['max'] as num).toDouble()
            : null,
        dataPoints: dataPoints
            .map((e) => TrendDataPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return [param];
    }
    throw Exception(data['message'] ?? 'Failed to load trends');
  }
}
