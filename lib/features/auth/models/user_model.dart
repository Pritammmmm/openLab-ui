class UserModel {
  final String id;
  final String firebaseUid;
  final String email;
  final String name;
  final String? photoUrl;
  final String preferredLanguage;
  final SubscriptionInfo subscription;
  final UsageInfo? usage;
  final LimitsInfo? limits;
  final bool onboardingCompleted;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.preferredLanguage = 'en',
    required this.subscription,
    this.usage,
    this.limits,
    this.onboardingCompleted = true,
    this.isActive = true,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      firebaseUid: json['firebaseUid'] as String? ?? json['firebase_uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? json['photo_url'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? json['preferred_language'] as String? ?? 'en',
      subscription: json['subscription'] != null
          ? SubscriptionInfo.fromJson(json['subscription'] as Map<String, dynamic>)
          : const SubscriptionInfo(),
      usage: json['usage'] != null
          ? UsageInfo.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      limits: json['limits'] != null
          ? LimitsInfo.fromJson(json['limits'] as Map<String, dynamic>)
          : null,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? json['onboardingCompleted'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      lastLoginAt: _parseDate(json['lastLoginAt'] ?? json['last_login_at']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firebaseUid': firebaseUid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'preferredLanguage': preferredLanguage,
      'subscription': subscription.toJson(),
      'onboardingCompleted': onboardingCompleted,
      'isActive': isActive,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? firebaseUid,
    String? email,
    String? name,
    String? photoUrl,
    String? preferredLanguage,
    SubscriptionInfo? subscription,
    UsageInfo? usage,
    LimitsInfo? limits,
    bool? onboardingCompleted,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      subscription: subscription ?? this.subscription,
      usage: usage ?? this.usage,
      limits: limits ?? this.limits,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SubscriptionInfo {
  final bool isPremium;
  final String? plan;
  final DateTime? expiresAt;
  final bool autoRenew;

  const SubscriptionInfo({
    this.isPremium = false,
    this.plan,
    this.expiresAt,
    this.autoRenew = false,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      isPremium: json['isPremium'] as bool? ?? false,
      plan: json['plan'] as String?,
      expiresAt: _parseDate(json['expiresAt']),
      autoRenew: json['autoRenew'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPremium': isPremium,
      'plan': plan,
      'expiresAt': expiresAt?.toIso8601String(),
      'autoRenew': autoRenew,
    };
  }
}

class UsageInfo {
  final int totalReports;
  final int todayUploads;
  final int monthUploads;
  final int profileCount;

  const UsageInfo({
    this.totalReports = 0,
    this.todayUploads = 0,
    this.monthUploads = 0,
    this.profileCount = 0,
  });

  factory UsageInfo.fromJson(Map<String, dynamic> json) {
    return UsageInfo(
      totalReports: json['total_reports'] as int? ?? 0,
      todayUploads: json['today_uploads'] as int? ?? 0,
      monthUploads: json['month_uploads'] as int? ?? 0,
      profileCount: json['profile_count'] as int? ?? 0,
    );
  }
}

class LimitsInfo {
  final int profiles;
  final int dailyUploads;
  final int monthlyUploads;
  final int? lifetimeUploads;

  const LimitsInfo({
    this.profiles = 1,
    this.dailyUploads = 5,
    this.monthlyUploads = 50,
    this.lifetimeUploads,
  });

  factory LimitsInfo.fromJson(Map<String, dynamic> json) {
    return LimitsInfo(
      profiles: json['profiles'] as int? ?? 1,
      dailyUploads: json['daily_uploads'] as int? ?? 5,
      monthlyUploads: json['monthly_uploads'] as int? ?? 50,
      lifetimeUploads: json['lifetime_uploads'] as int?,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
