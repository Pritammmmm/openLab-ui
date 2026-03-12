import 'parameter_model.dart';

class ReportModel {
  final String id;
  final String userId;
  final String profileId;
  final String? labName;
  final DateTime? reportDate;
  final DateTime uploadDate;
  final FileInfo file;
  final String status;
  final String? aiSummary;
  final String? aiComparisonSummary;
  final String? overallStatus;
  final StatusCounts statusCounts;
  final HealthScore? healthScore;
  final List<ParameterModel> parameters;
  final ProcessingInfo processing;

  const ReportModel({
    required this.id,
    required this.userId,
    required this.profileId,
    this.labName,
    this.reportDate,
    required this.uploadDate,
    required this.file,
    this.status = 'processing',
    this.aiSummary,
    this.aiComparisonSummary,
    this.overallStatus,
    required this.statusCounts,
    this.healthScore,
    this.parameters = const [],
    required this.processing,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      profileId: json['profileId'] as String? ?? '',
      labName: json['labName'] as String?,
      reportDate: json['reportDate'] != null
          ? DateTime.tryParse(json['reportDate'] as String)
          : null,
      uploadDate: json['uploadDate'] != null
          ? DateTime.parse(json['uploadDate'] as String)
          : DateTime.now(),
      file: json['file'] != null
          ? FileInfo.fromJson(json['file'] as Map<String, dynamic>)
          : const FileInfo(),
      status: json['status'] as String? ?? 'processing',
      aiSummary: json['aiSummary'] as String?,
      aiComparisonSummary: json['aiComparisonSummary'] as String?,
      overallStatus: json['overallStatus'] as String?,
      statusCounts: json['statusCounts'] != null
          ? StatusCounts.fromJson(json['statusCounts'] as Map<String, dynamic>)
          : const StatusCounts(),
      healthScore: json['healthScore'] != null
          ? HealthScore.fromJson(json['healthScore'] as Map<String, dynamic>)
          : null,
      parameters: (json['parameters'] as List<dynamic>?)
              ?.map((e) => ParameterModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      processing: json['processing'] != null
          ? ProcessingInfo.fromJson(json['processing'] as Map<String, dynamic>)
          : const ProcessingInfo(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'profileId': profileId,
      'labName': labName,
      'reportDate': reportDate?.toIso8601String(),
      'uploadDate': uploadDate.toIso8601String(),
      'file': file.toJson(),
      'status': status,
      'aiSummary': aiSummary,
      'aiComparisonSummary': aiComparisonSummary,
      'overallStatus': overallStatus,
      'statusCounts': statusCounts.toJson(),
      'parameters': parameters.map((e) => e.toJson()).toList(),
      'processing': processing.toJson(),
    };
  }

  ReportModel copyWith({
    String? id,
    String? userId,
    String? profileId,
    String? labName,
    DateTime? reportDate,
    DateTime? uploadDate,
    FileInfo? file,
    String? status,
    String? aiSummary,
    String? aiComparisonSummary,
    String? overallStatus,
    StatusCounts? statusCounts,
    List<ParameterModel>? parameters,
    ProcessingInfo? processing,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileId: profileId ?? this.profileId,
      labName: labName ?? this.labName,
      reportDate: reportDate ?? this.reportDate,
      uploadDate: uploadDate ?? this.uploadDate,
      file: file ?? this.file,
      status: status ?? this.status,
      aiSummary: aiSummary ?? this.aiSummary,
      aiComparisonSummary: aiComparisonSummary ?? this.aiComparisonSummary,
      overallStatus: overallStatus ?? this.overallStatus,
      statusCounts: statusCounts ?? this.statusCounts,
      parameters: parameters ?? this.parameters,
      processing: processing ?? this.processing,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isProcessing => status == 'processing';
  bool get isFailed => status == 'failed';

  Map<String, List<ParameterModel>> get parametersByCategory {
    final map = <String, List<ParameterModel>>{};
    for (final param in parameters) {
      final cat = param.category ?? 'Other';
      map.putIfAbsent(cat, () => []).add(param);
    }
    return map;
  }
}

class FileInfo {
  final String? originalName;
  final String? mimeType;
  final int? size;
  final String? url;

  const FileInfo({
    this.originalName,
    this.mimeType,
    this.size,
    this.url,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      originalName: json['originalName'] as String?,
      mimeType: json['mimeType'] as String? ?? json['fileType'] as String?,
      size: json['size'] as int? ?? json['sizeBytes'] as int?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalName': originalName,
      'mimeType': mimeType,
      'size': size,
      'url': url,
    };
  }
}

class HealthScore {
  final int? score;
  final String label;
  final List<CategoryScore> categoryScores;
  final ScoreCoverage coverage;
  final int penaltiesApplied;

  const HealthScore({
    this.score,
    this.label = 'No Data',
    this.categoryScores = const [],
    this.coverage = const ScoreCoverage(),
    this.penaltiesApplied = 0,
  });

  factory HealthScore.fromJson(Map<String, dynamic> json) {
    return HealthScore(
      score: (json['score'] as num?)?.toInt(),
      label: json['label'] as String? ?? 'No Data',
      categoryScores: (json['categoryScores'] as List<dynamic>?)
              ?.map((e) => CategoryScore.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      coverage: json['coverage'] != null
          ? ScoreCoverage.fromJson(json['coverage'] as Map<String, dynamic>)
          : const ScoreCoverage(),
      penaltiesApplied: (json['penaltiesApplied'] as num?)?.toInt() ?? 0,
    );
  }
}

class CategoryScore {
  final String category;
  final String label;
  final int weight;
  final int? score;
  final int markersFound;
  final int markersTotal;
  final String status;

  const CategoryScore({
    required this.category,
    required this.label,
    required this.weight,
    this.score,
    this.markersFound = 0,
    this.markersTotal = 0,
    this.status = 'unknown',
  });

  factory CategoryScore.fromJson(Map<String, dynamic> json) {
    return CategoryScore(
      category: json['category'] as String? ?? '',
      label: json['label'] as String? ?? '',
      weight: (json['weight'] as num?)?.toInt() ?? 1,
      score: (json['score'] as num?)?.toInt(),
      markersFound: (json['markersFound'] as num?)?.toInt() ?? 0,
      markersTotal: (json['markersTotal'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'unknown',
    );
  }
}

class ScoreCoverage {
  final int found;
  final int total;
  final int percentage;
  final bool sufficient;

  const ScoreCoverage({
    this.found = 0,
    this.total = 0,
    this.percentage = 0,
    this.sufficient = false,
  });

  factory ScoreCoverage.fromJson(Map<String, dynamic> json) {
    return ScoreCoverage(
      found: (json['found'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
      sufficient: json['sufficient'] as bool? ?? false,
    );
  }
}

class StatusCounts {
  final int green;
  final int yellow;
  final int red;

  const StatusCounts({
    this.green = 0,
    this.yellow = 0,
    this.red = 0,
  });

  factory StatusCounts.fromJson(Map<String, dynamic> json) {
    return StatusCounts(
      green: json['green'] as int? ?? 0,
      yellow: json['yellow'] as int? ?? 0,
      red: json['red'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'green': green, 'yellow': yellow, 'red': red};
  }

  int get total => green + yellow + red;
}

class ProcessingInfo {
  final String? ocrEngine;
  final String? aiModel;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? durationMs;
  final String? errorMessage;

  const ProcessingInfo({
    this.ocrEngine,
    this.aiModel,
    this.startedAt,
    this.completedAt,
    this.durationMs,
    this.errorMessage,
  });

  factory ProcessingInfo.fromJson(Map<String, dynamic> json) {
    return ProcessingInfo(
      ocrEngine: json['ocrEngine'] as String?,
      aiModel: json['aiModel'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      durationMs: json['durationMs'] as int? ?? json['timeMs'] as int?,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ocrEngine': ocrEngine,
      'aiModel': aiModel,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'durationMs': durationMs,
      'errorMessage': errorMessage,
    };
  }
}
