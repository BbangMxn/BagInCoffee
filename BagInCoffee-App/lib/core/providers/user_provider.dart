import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../api/api.dart' as api;
import '../../shared/models/user_profile.dart';
import 'auth_provider.dart';

/// SharedPreferences 프로바이더 (앱 시작 시 초기화 필요)
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

/// 캐시 키
const String _profileCacheKey = 'cached_user_profile';
const String _profileCacheTimeKey = 'cached_user_profile_time';
const int _cacheValidityMinutes = 30;

/// 현재 사용자 프로필 Provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
      final supabase = ref.watch(supabaseProvider);
      final prefs = ref.watch(sharedPrefsProvider);
      return UserProfileNotifier(supabase, prefs);
    });

/// 프로필 Notifier - 동기 캐시 로드로 빠른 초기화
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final SupabaseClient _supabase;
  final SharedPreferences _prefs;

  UserProfileNotifier(this._supabase, this._prefs)
    : super(const AsyncValue.loading()) {
    _initSync();
  }

  /// 동기 초기화 - 캐시에서 즉시 로드
  void _initSync() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }

    // 동기로 캐시에서 즉시 로드
    final cached = _loadFromCacheSync();
    if (cached != null && cached.id == user.id) {
      state = AsyncValue.data(cached);

      // 캐시가 오래됐으면 백그라운드에서 새로고침
      if (_isCacheExpired()) {
        _refreshInBackground();
      }
    } else {
      // 캐시 없으면 서버에서 가져오기
      refresh();
    }
  }

  /// 캐시 만료 확인
  bool _isCacheExpired() {
    final cacheTime = _prefs.getInt(_profileCacheTimeKey);
    if (cacheTime == null) return true;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cacheTime);
    return DateTime.now().difference(cachedAt).inMinutes >
        _cacheValidityMinutes;
  }

  /// 백그라운드에서 새로고침 (API 사용)
  void _refreshInBackground() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final apiProfile = await api.usersApi.getMe();
      final profile = _convertToLocalProfile(apiProfile);
      _saveToCacheSync(profile);

      if (mounted) {
        state = AsyncValue.data(profile);
      }
    } catch (_) {
      // 백그라운드 실패는 무시
    }
  }

  /// API 프로필을 로컬 프로필로 변환
  UserProfile _convertToLocalProfile(api.UserProfile apiProfile) {
    return UserProfile(
      id: apiProfile.id,
      username: apiProfile.username,
      avatarUrl: apiProfile.avatarUrl,
      coverImageUrl: apiProfile.coverImageUrl,
      bio: apiProfile.bio,
      location: apiProfile.location,
      website: apiProfile.website,
      role: UserRole.fromString(apiProfile.role.toJson()),
      avatarUpdatedAt: apiProfile.avatarUpdatedAt,
      createdAt: apiProfile.createdAt,
      updatedAt: apiProfile.updatedAt,
    );
  }

  /// 프로필 새로고침 (Supabase에서 직접)
  Future<void> refresh() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      state = const AsyncValue.data(null);
      _clearCacheSync();
      return;
    }

    try {
      final profile = await _fetchFromSupabase(user.id);
      if (profile != null) {
        _saveToCacheSync(profile);
        state = AsyncValue.data(profile);
      }
    } catch (e) {
      // 캐시된 데이터가 있으면 유지
      if (state.valueOrNull != null) {
        return;
      }
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Supabase에서 직접 프로필 가져오기 (fallback)
  Future<UserProfile?> _fetchFromSupabase(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserProfile(
      id: response['id'] as String,
      username: response['username'] as String?,
      avatarUrl: response['avatar_url'] as String?,
      coverImageUrl: response['cover_image_url'] as String?,
      bio: response['bio'] as String?,
      location: response['location'] as String?,
      website: response['website'] as String?,
      role: UserRole.fromString(response['role'] as String? ?? 'user'),
      avatarUpdatedAt: response['avatar_updated_at'] != null
          ? DateTime.parse(response['avatar_updated_at'] as String)
          : null,
      createdAt: DateTime.parse(response['created_at'] as String),
      updatedAt: DateTime.parse(response['updated_at'] as String),
    );
  }

  /// 프로필 업데이트
  Future<bool> updateProfile(UpdateProfileDto dto) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      final apiDto = api.UpdateProfileDto(
        username: dto.username,
        avatarUrl: dto.avatarUrl,
        coverImageUrl: dto.coverImageUrl,
        bio: dto.bio,
        location: dto.location,
        website: dto.website,
      );
      final apiProfile = await api.usersApi.updateProfile(apiDto);
      final profile = _convertToLocalProfile(apiProfile);
      _saveToCacheSync(profile);
      state = AsyncValue.data(profile);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 로그아웃 시 클리어
  void clear() {
    _clearCacheSync();
    state = const AsyncValue.data(null);
  }

  /// 동기로 캐시에서 로드
  UserProfile? _loadFromCacheSync() {
    try {
      final json = _prefs.getString(_profileCacheKey);
      if (json == null) return null;

      final data = jsonDecode(json) as Map<String, dynamic>;
      return UserProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// 동기로 캐시에 저장
  void _saveToCacheSync(UserProfile profile) {
    try {
      final json = jsonEncode(profile.toJson());
      _prefs.setString(_profileCacheKey, json);
      _prefs.setInt(
        _profileCacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  /// 동기로 캐시 삭제
  void _clearCacheSync() {
    try {
      _prefs.remove(_profileCacheKey);
      _prefs.remove(_profileCacheTimeKey);
    } catch (_) {}
  }
}

/// ID로 다른 사용자 프로필 가져오기
final otherUserProfileProvider = FutureProvider.family<UserProfile?, String>((
  ref,
  userId,
) async {
  try {
    final apiProfile = await api.usersApi.getById(userId);
    return UserProfile(
      id: apiProfile.id,
      username: apiProfile.username,
      avatarUrl: apiProfile.avatarUrl,
      coverImageUrl: apiProfile.coverImageUrl,
      bio: apiProfile.bio,
      location: apiProfile.location,
      website: apiProfile.website,
      role: UserRole.fromString(apiProfile.role.toJson()),
      avatarUpdatedAt: apiProfile.avatarUpdatedAt,
      createdAt: apiProfile.createdAt,
      updatedAt: apiProfile.updatedAt,
    );
  } catch (e) {
    return null;
  }
});

/// Username으로 프로필 가져오기
final userProfileByUsernameProvider =
    FutureProvider.family<UserProfile?, String>((ref, username) async {
      try {
        final apiProfile = await api.usersApi.getByUsername(username);
        return UserProfile(
          id: apiProfile.id,
          username: apiProfile.username,
          avatarUrl: apiProfile.avatarUrl,
          coverImageUrl: apiProfile.coverImageUrl,
          bio: apiProfile.bio,
          location: apiProfile.location,
          website: apiProfile.website,
          role: UserRole.fromString(apiProfile.role.toJson()),
          avatarUpdatedAt: apiProfile.avatarUpdatedAt,
          createdAt: apiProfile.createdAt,
          updatedAt: apiProfile.updatedAt,
        );
      } catch (e) {
        return null;
      }
    });
