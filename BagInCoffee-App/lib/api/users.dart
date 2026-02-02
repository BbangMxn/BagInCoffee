import 'client.dart';

/// 사용자 권한
enum UserRole {
  user,
  admin,
  subAdmin,
  moderator;

  String toJson() {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.admin:
        return 'admin';
      case UserRole.subAdmin:
        return 'sub_admin';
      case UserRole.moderator:
        return 'moderator';
    }
  }

  static UserRole fromJson(String json) {
    switch (json) {
      case 'admin':
        return UserRole.admin;
      case 'sub_admin':
        return UserRole.subAdmin;
      case 'moderator':
        return UserRole.moderator;
      default:
        return UserRole.user;
    }
  }
}

/// 사용자 프로필 모델
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

  UserProfile({
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
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
      coverImageUrl: json['cover_image_url'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      role: UserRole.fromJson(json['role'] ?? 'user'),
      avatarUpdatedAt: json['avatar_updated_at'] != null
          ? DateTime.parse(json['avatar_updated_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
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

/// 간단한 사용자 프로필
class UserProfileSimple {
  final String id;
  final String? username;
  final String? avatarUrl;

  UserProfileSimple({required this.id, this.username, this.avatarUrl});

  factory UserProfileSimple.fromJson(Map<String, dynamic> json) {
    return UserProfileSimple(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
    );
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

  UpdateProfileDto({
    this.username,
    this.avatarUrl,
    this.coverImageUrl,
    this.bio,
    this.location,
    this.website,
  });

  Map<String, dynamic> toJson() => {
    if (username != null) 'username': username,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
    if (bio != null) 'bio': bio,
    if (location != null) 'location': location,
    if (website != null) 'website': website,
  };
}

/// Users API
class UsersApi {
  final ApiClient _client = ApiClient();

  /// 현재 사용자 프로필 조회
  Future<UserProfile> getMe() async {
    final response = await _client.get('/api/users/me', requiresAuth: true);
    return UserProfile.fromJson(response);
  }

  /// 사용자 프로필 조회
  Future<UserProfile> getById(String id) async {
    final response = await _client.get('/api/users/$id');
    return UserProfile.fromJson(response);
  }

  /// 사용자명으로 프로필 조회
  Future<UserProfile> getByUsername(String username) async {
    final response = await _client.get('/api/users/username/$username');
    return UserProfile.fromJson(response);
  }

  /// 프로필 업데이트
  Future<UserProfile> updateProfile(UpdateProfileDto dto) async {
    final response = await _client.put('/api/users/me', data: dto.toJson());
    return UserProfile.fromJson(response);
  }

  /// 사용자명 중복 확인
  Future<bool> checkUsernameAvailable(String username) async {
    final response = await _client.get('/api/users/check-username/$username');
    return (response as Map<String, dynamic>)['available'] ?? false;
  }

  /// 사용자 검색
  Future<List<UserProfileSimple>> search(String query, {int? limit}) async {
    final queryParams = <String, dynamic>{'q': query};
    if (limit != null) queryParams['limit'] = limit;

    final response = await _client.get(
      '/api/users/search',
      queryParameters: queryParams,
    );
    return (response as List)
        .map((e) => UserProfileSimple.fromJson(e))
        .toList();
  }

  /// 팔로우
  Future<void> follow(String userId) async {
    await _client.post('/api/users/$userId/follow');
  }

  /// 언팔로우
  Future<void> unfollow(String userId) async {
    await _client.delete('/api/users/$userId/follow');
  }

  /// 팔로워 목록
  Future<List<UserProfileSimple>> getFollowers(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await _client.get(
      '/api/users/$userId/followers',
      queryParameters: queryParams,
    );
    return (response as List)
        .map((e) => UserProfileSimple.fromJson(e))
        .toList();
  }

  /// 팔로잉 목록
  Future<List<UserProfileSimple>> getFollowing(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await _client.get(
      '/api/users/$userId/following',
      queryParameters: queryParams,
    );
    return (response as List)
        .map((e) => UserProfileSimple.fromJson(e))
        .toList();
  }
}

final usersApi = UsersApi();
