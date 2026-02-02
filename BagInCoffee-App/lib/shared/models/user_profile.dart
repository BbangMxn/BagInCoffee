/// 사용자 권한
enum UserRole {
  user,
  admin,
  subadmin,
  moderator;

  factory UserRole.fromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'subadmin':
      case 'sub_admin':
        return UserRole.subadmin;
      case 'moderator':
        return UserRole.moderator;
      default:
        return UserRole.user;
    }
  }

  String toJson() {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.subadmin:
        return 'subadmin';
      case UserRole.moderator:
        return 'moderator';
      default:
        return 'user';
    }
  }
}

/// 사용자 프로필
class UserProfile {
  final String id;
  final String? username;
  final String? avatarUrl;
  final String? coverImageUrl;
  final String? bio;
  final String? location;
  final String? website;
  final UserRole role;
  final DateTime? avatarUpdatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.username,
    this.avatarUrl,
    this.coverImageUrl,
    this.bio,
    this.location,
    this.website,
    this.role = UserRole.user,
    this.avatarUpdatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
      avatarUpdatedAt: json['avatar_updated_at'] != null
          ? DateTime.parse(json['avatar_updated_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'cover_image_url': coverImageUrl,
      'bio': bio,
      'location': location,
      'website': website,
      'role': role.toJson(),
      'avatar_updated_at': avatarUpdatedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 표시용 이름
  String get displayName => username ?? 'User';

  UserProfile copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? coverImageUrl,
    String? bio,
    String? location,
    String? website,
    UserRole? role,
    DateTime? avatarUpdatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      role: role ?? this.role,
      avatarUpdatedAt: avatarUpdatedAt ?? this.avatarUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 간단한 사용자 프로필 (리스트/카드용)
class UserProfileSimple {
  final String id;
  final String? username;
  final String? avatarUrl;

  const UserProfileSimple({required this.id, this.username, this.avatarUrl});

  factory UserProfileSimple.fromJson(Map<String, dynamic> json) {
    return UserProfileSimple(
      id: json['id'] as String,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'avatar_url': avatarUrl};
  }
}

/// 프로필 업데이트 DTO
class UpdateProfileDto {
  final String? username;
  final String? avatarUrl;
  final String? coverImageUrl;
  final String? bio;
  final String? location;
  final String? website;

  const UpdateProfileDto({
    this.username,
    this.avatarUrl,
    this.coverImageUrl,
    this.bio,
    this.location,
    this.website,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (username != null) map['username'] = username;
    if (avatarUrl != null) map['avatar_url'] = avatarUrl;
    if (coverImageUrl != null) map['cover_image_url'] = coverImageUrl;
    if (bio != null) map['bio'] = bio;
    if (location != null) map['location'] = location;
    if (website != null) map['website'] = website;
    return map;
  }
}
