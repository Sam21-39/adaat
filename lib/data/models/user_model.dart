/// User model for local storage
class UserModel {
  final String id;
  final String? email;
  final String? phone;
  final String displayName;
  final String? avatarUrl;
  final String language; // en, hi, hinglish
  final bool isPremium;
  final DateTime? premiumUntil;
  final String? referralCode;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.id,
    this.email,
    this.phone,
    required this.displayName,
    this.avatarUrl,
    this.language = 'en',
    this.isPremium = false,
    this.premiumUntil,
    this.referralCode,
    DateTime? createdAt,
    DateTime? lastActive,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastActive = lastActive ?? DateTime.now();

  /// Create from database map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      displayName: map['display_name'] as String,
      avatarUrl: map['avatar_url'] as String?,
      language: map['language'] as String? ?? 'en',
      isPremium: (map['is_premium'] as int?) == 1,
      premiumUntil: map['premium_until'] != null
          ? DateTime.parse(map['premium_until'] as String)
          : null,
      referralCode: map['referral_code'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastActive: DateTime.parse(map['last_active'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'language': language,
      'is_premium': isPremium ? 1 : 0,
      'premium_until': premiumUntil?.toIso8601String(),
      'referral_code': referralCode,
      'created_at': createdAt.toIso8601String(),
      'last_active': lastActive.toIso8601String(),
    };
  }

  /// Copy with modifications
  UserModel copyWith({
    String? email,
    String? phone,
    String? displayName,
    String? avatarUrl,
    String? language,
    bool? isPremium,
    DateTime? premiumUntil,
    String? referralCode,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      referralCode: referralCode ?? this.referralCode,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  /// Get first name for greeting
  String get firstName => displayName.split(' ').first;

  @override
  String toString() {
    return 'UserModel(id: $id, displayName: $displayName, email: $email)';
  }
}
