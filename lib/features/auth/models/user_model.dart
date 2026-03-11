class UserModel {
  final String id;
  final String firebaseUid;
  final String email;
  final String name;
  final String? photoUrl;
  final String preferredLanguage;
  final SubscriptionInfo subscription;
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
    this.isActive = true,
    this.lastLoginAt,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      firebaseUid: json['firebaseUid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      subscription: json['subscription'] != null
          ? SubscriptionInfo.fromJson(json['subscription'] as Map<String, dynamic>)
          : const SubscriptionInfo(),
      isActive: json['isActive'] as bool? ?? true,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
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
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
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
