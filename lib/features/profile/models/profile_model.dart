class ProfileModel {
  final String id;
  final String userId;
  final String name;
  final DateTime? dateOfBirth;
  final int age;
  final String gender;
  final String relation;
  final String avatarColor;
  final bool isDefault;
  final int reportCount;
  final DateTime? lastReportDate;

  const ProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    this.dateOfBirth,
    this.age = 0,
    this.gender = 'other',
    this.relation = 'self',
    this.avatarColor = '#0D6B4F',
    this.isDefault = false,
    this.reportCount = 0,
    this.lastReportDate,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? 'other',
      relation: json['relation'] as String? ?? 'self',
      avatarColor: json['avatarColor'] as String? ?? '#0D6B4F',
      isDefault: json['isDefault'] as bool? ?? false,
      reportCount: json['reportCount'] as int? ?? 0,
      lastReportDate: json['lastReportDate'] != null
          ? DateTime.tryParse(json['lastReportDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'name': name,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'age': age,
      'gender': gender,
      'relation': relation,
      'avatarColor': avatarColor,
      'isDefault': isDefault,
      'reportCount': reportCount,
      'lastReportDate': lastReportDate?.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? dateOfBirth,
    int? age,
    String? gender,
    String? relation,
    String? avatarColor,
    bool? isDefault,
    int? reportCount,
    DateTime? lastReportDate,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      relation: relation ?? this.relation,
      avatarColor: avatarColor ?? this.avatarColor,
      isDefault: isDefault ?? this.isDefault,
      reportCount: reportCount ?? this.reportCount,
      lastReportDate: lastReportDate ?? this.lastReportDate,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
