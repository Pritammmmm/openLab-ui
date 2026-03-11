import 'report_model.dart';

class ReportSummaryModel {
  final String id;
  final String profileId;
  final String? labName;
  final DateTime? reportDate;
  final DateTime uploadDate;
  final String status;
  final String? overallStatus;
  final StatusCounts statusCounts;
  final int parameterCount;

  const ReportSummaryModel({
    required this.id,
    required this.profileId,
    this.labName,
    this.reportDate,
    required this.uploadDate,
    this.status = 'processing',
    this.overallStatus,
    required this.statusCounts,
    this.parameterCount = 0,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      profileId: json['profileId'] as String? ?? '',
      labName: json['labName'] as String?,
      reportDate: json['reportDate'] != null
          ? DateTime.tryParse(json['reportDate'] as String)
          : null,
      uploadDate: json['uploadDate'] != null
          ? DateTime.parse(json['uploadDate'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'processing',
      overallStatus: json['overallStatus'] as String?,
      statusCounts: json['statusCounts'] != null
          ? StatusCounts.fromJson(json['statusCounts'] as Map<String, dynamic>)
          : const StatusCounts(),
      parameterCount: json['parameterCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'profileId': profileId,
      'labName': labName,
      'reportDate': reportDate?.toIso8601String(),
      'uploadDate': uploadDate.toIso8601String(),
      'status': status,
      'overallStatus': overallStatus,
      'statusCounts': statusCounts.toJson(),
      'parameterCount': parameterCount,
    };
  }

  bool get isCompleted => status == 'completed';
}
