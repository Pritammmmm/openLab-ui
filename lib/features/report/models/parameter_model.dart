class ParameterModel {
  final String? parameterRef;
  final String name;
  final String? shortName;
  final String? category;
  final double value;
  final String unit;
  final ReferenceRange? refRange;
  final String status;
  final String trafficLight;
  final String? aiExplanation;
  final ComparisonInfo? comparison;

  const ParameterModel({
    this.parameterRef,
    required this.name,
    this.shortName,
    this.category,
    required this.value,
    required this.unit,
    this.refRange,
    required this.status,
    required this.trafficLight,
    this.aiExplanation,
    this.comparison,
  });

  factory ParameterModel.fromJson(Map<String, dynamic> json) {
    return ParameterModel(
      parameterRef: json['parameterRef'] as String?,
      name: json['name'] as String? ?? '',
      shortName: json['shortName'] as String?,
      category: json['category'] as String?,
      value: (json['value'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      refRange: json['refRange'] != null
          ? ReferenceRange.fromJson(json['refRange'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? 'normal',
      trafficLight: json['trafficLight'] as String? ?? 'green',
      aiExplanation: json['aiExplanation'] as String?,
      comparison: json['comparison'] != null
          ? ComparisonInfo.fromJson(json['comparison'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameterRef': parameterRef,
      'name': name,
      'shortName': shortName,
      'category': category,
      'value': value,
      'unit': unit,
      'refRange': refRange?.toJson(),
      'status': status,
      'trafficLight': trafficLight,
      'aiExplanation': aiExplanation,
      'comparison': comparison?.toJson(),
    };
  }

  ParameterModel copyWith({
    String? parameterRef,
    String? name,
    String? shortName,
    String? category,
    double? value,
    String? unit,
    ReferenceRange? refRange,
    String? status,
    String? trafficLight,
    String? aiExplanation,
    ComparisonInfo? comparison,
  }) {
    return ParameterModel(
      parameterRef: parameterRef ?? this.parameterRef,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      category: category ?? this.category,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      refRange: refRange ?? this.refRange,
      status: status ?? this.status,
      trafficLight: trafficLight ?? this.trafficLight,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      comparison: comparison ?? this.comparison,
    );
  }
}

class ReferenceRange {
  final double? min;
  final double? max;

  const ReferenceRange({this.min, this.max});

  factory ReferenceRange.fromJson(Map<String, dynamic> json) {
    return ReferenceRange(
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'min': min, 'max': max};
  }

  String get displayRange {
    if (min != null && max != null) return '${min!.toStringAsFixed(1)} - ${max!.toStringAsFixed(1)}';
    if (min != null) return '> ${min!.toStringAsFixed(1)}';
    if (max != null) return '< ${max!.toStringAsFixed(1)}';
    return 'N/A';
  }
}

class ComparisonInfo {
  final double? previousValue;
  final String? trend;
  final double? changePct;

  const ComparisonInfo({
    this.previousValue,
    this.trend,
    this.changePct,
  });

  factory ComparisonInfo.fromJson(Map<String, dynamic> json) {
    return ComparisonInfo(
      previousValue: (json['previousValue'] as num?)?.toDouble(),
      trend: json['trend'] as String?,
      changePct: (json['changePct'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'previousValue': previousValue,
      'trend': trend,
      'changePct': changePct,
    };
  }
}
