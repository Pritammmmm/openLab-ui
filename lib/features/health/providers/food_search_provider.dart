import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/providers/core_providers.dart';

class FoodSearchResult {
  final String id;
  final String name;
  final String category;
  final int caloriesPer100g;

  const FoodSearchResult({
    required this.id,
    required this.name,
    required this.category,
    required this.caloriesPer100g,
  });

  factory FoodSearchResult.fromJson(Map<String, dynamic> json) {
    return FoodSearchResult(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      caloriesPer100g:
          ((json['calories_per_100g'] ?? json['caloriesPer100g']) as num?)
                  ?.toInt() ??
              0,
    );
  }
}

final foodSearchQueryProvider = StateProvider<String>((ref) => '');

final foodSearchResultsProvider =
    FutureProvider.autoDispose<List<FoodSearchResult>>((ref) async {
  final query = ref.watch(foodSearchQueryProvider);
  if (query.trim().length < 2) return [];

  final dio = ref.watch(dioClientProvider).dio;
  final response = await dio.get(
    ApiEndpoints.foodDbSearch,
    queryParameters: {'q': query, 'limit': 15},
  );

  final raw = response.data;
  final List items;
  if (raw is Map && raw.containsKey('data')) {
    items = raw['data'] as List? ?? [];
  } else if (raw is List) {
    items = raw;
  } else {
    items = [];
  }
  return items
      .map((e) => FoodSearchResult.fromJson(e as Map<String, dynamic>))
      .toList();
});
