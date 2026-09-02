import 'dart:convert';

import 'package:drift/drift.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb);
    if (decoded is! List) return const [];
    return decoded.map((item) => item.toString()).toList(growable: false);
  }

  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}

class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb);
    if (decoded is! List) return const [];
    return decoded
        .map((item) => item is int ? item : int.parse(item.toString()))
        .toList(growable: false);
  }

  @override
  String toSql(List<int> value) {
    return jsonEncode(value);
  }
}
