import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/recode/data/brew_log_provider.dart';
import '../../features/guide/data/guide_provider.dart';
import '../../features/home/data/post_provider.dart';
import '../../features/magazine/data/article_provider.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

/// 인증 상태 (로그인/로그아웃 추적용)
enum AuthStatus { authenticated, unauthenticated, loading }

/// 인증 상태 Provider - authStateProvider 스트림을 listen해서 자동 업데이트
final authStatusProvider =
    StateNotifierProvider<AuthStatusNotifier, AuthStatus>((ref) {
      return AuthStatusNotifier(ref);
    });

class AuthStatusNotifier extends StateNotifier<AuthStatus> {
  final Ref _ref;

  AuthStatusNotifier(this._ref) : super(AuthStatus.unauthenticated) {
    // 초기 상태 설정
    final session = _ref.read(currentSessionProvider);
    state = session != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    if (kDebugMode) print('🔐 AuthStatusNotifier 초기 상태: $state');

    // auth 상태 변경 listen
    _ref.listen(authStateProvider, (previous, next) {
      next.whenData((authState) {
        if (kDebugMode) {
          print(
            '🔄 authStateProvider 변경 감지: session=${authState.session != null}',
          );
        }
        if (authState.session != null) {
          if (kDebugMode) print('✅ 인증됨 -> AuthStatus.authenticated');
          state = AuthStatus.authenticated;
        } else {
          if (kDebugMode) print('❌ 미인증 -> AuthStatus.unauthenticated');
          state = AuthStatus.unauthenticated;
        }
      });
    });
  }

  void setLoading() {
    if (kDebugMode) print('⏳ AuthStatus -> loading');
    state = AuthStatus.loading;
  }

  void setAuthenticated() {
    if (kDebugMode) print('✅ AuthStatus -> authenticated (수동)');
    state = AuthStatus.authenticated;
  }

  void setUnauthenticated() {
    if (kDebugMode) print('❌ AuthStatus -> unauthenticated (수동)');
    state = AuthStatus.unauthenticated;
  }
}

/// 중앙 집중식 인증 관리자
class AuthManager {
  final WidgetRef _ref;

  AuthManager(this._ref);

  /// 로그아웃 - 모든 상태 초기화
  Future<void> signOut() async {
    if (kDebugMode) print('🚪 signOut 시작');

    // 1. 상태를 로딩으로 변경
    _ref.read(authStatusProvider.notifier).setLoading();

    try {
      // 2. Supabase 로그아웃
      if (kDebugMode) print('📤 Supabase 로그아웃 호출');
      final supabase = _ref.read(supabaseProvider);
      await supabase.auth.signOut();
      if (kDebugMode) print('✅ Supabase 로그아웃 완료');

      // 3. 사용자 프로필 클리어
      if (kDebugMode) print('🗑️ 프로필 클리어');
      _ref.read(userProfileProvider.notifier).clear();

      // 4. 모든 캐시된 데이터 초기화
      if (kDebugMode) print('🔄 모든 Provider 초기화');
      _invalidateAllProviders();

      // 5. 상태를 미인증으로 변경 (authStateProvider가 자동으로 처리하지만 명시적으로도 설정)
      _ref.read(authStatusProvider.notifier).setUnauthenticated();
      if (kDebugMode) print('✅ signOut 완료');
    } catch (e) {
      if (kDebugMode) print('❌ signOut 에러: $e');
      // 에러가 나도 로그아웃 처리
      _ref.read(authStatusProvider.notifier).setUnauthenticated();
      rethrow;
    }
  }

  /// 로그인 후 데이터 새로고침
  Future<void> onLoginSuccess() async {
    if (kDebugMode) print('🔄 onLoginSuccess 시작');
    _ref.read(authStatusProvider.notifier).setAuthenticated();

    try {
      // 프로필 새로고침
      if (kDebugMode) print('👤 프로필 새로고침 중...');
      await _ref.read(userProfileProvider.notifier).refresh();
      if (kDebugMode) print('✅ 프로필 로드 완료');
    } catch (e) {
      // 프로필 로드 실패해도 로그인은 성공으로 처리
      debugPrint('⚠️ 프로필 로드 실패: $e');
    }

    // 모든 데이터 새로고침
    if (kDebugMode) print('🔄 모든 Provider 초기화');
    _invalidateAllProviders();
    if (kDebugMode) print('✅ onLoginSuccess 완료');
  }

  /// 모든 Provider 초기화
  void _invalidateAllProviders() {
    // Brew logs
    _ref.invalidate(myBrewLogsProvider);
    _ref.invalidate(favoriteBrewLogsProvider);

    // Guides
    _ref.invalidate(guidesProvider);
    _ref.invalidate(featuredGuidesProvider);

    // Posts
    _ref.invalidate(postsProvider);
    _ref.invalidate(popularPostsProvider);

    // Articles
    _ref.invalidate(articlesProvider);
  }
}

/// AuthManager Provider
final authManagerProvider = Provider.autoDispose<AuthManager>((ref) {
  throw UnimplementedError('AuthManager requires WidgetRef');
});

/// WidgetRef를 사용해서 AuthManager 생성
AuthManager getAuthManager(WidgetRef ref) => AuthManager(ref);
