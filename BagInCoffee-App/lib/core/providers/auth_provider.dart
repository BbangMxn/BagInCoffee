import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/recode/data/brew_log_provider.dart';
import '../../features/guide/data/guide_provider.dart';
import '../../features/home/data/post_provider.dart';
import '../../features/magazine/data/article_provider.dart';

/// Supabase 클라이언트 프로바이더
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// 현재 인증 상태 스트림 프로바이더
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

/// 현재 사용자 프로바이더
final currentUserProvider = Provider<User?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.currentUser;
});

/// 현재 세션 프로바이더
final currentSessionProvider = Provider<Session?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.currentSession;
});

/// 로그인 여부 프로바이더
final isLoggedInProvider = Provider<bool>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session != null;
});

/// 통합 전역 Auth 상태 Provider - 모든 위젯이 이것을 watch
final globalAuthStateProvider = Provider<GlobalAuthState>((ref) {
  // authStateProvider 스트림 watch
  final authStateAsync = ref.watch(authStateProvider);
  final session = ref.watch(currentSessionProvider);
  final user = ref.watch(currentUserProvider);

  final isLoggedIn = session != null && user != null;

  return GlobalAuthState(isLoggedIn: isLoggedIn, user: user, session: session);
});

/// 전역 Auth 상태 모델
class GlobalAuthState {
  final bool isLoggedIn;
  final User? user;
  final Session? session;

  const GlobalAuthState({required this.isLoggedIn, this.user, this.session});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobalAuthState &&
          runtimeType == other.runtimeType &&
          isLoggedIn == other.isLoggedIn &&
          user?.id == other.user?.id &&
          session?.accessToken == other.session?.accessToken;

  @override
  int get hashCode =>
      isLoggedIn.hashCode ^
      (user?.id.hashCode ?? 0) ^
      (session?.accessToken.hashCode ?? 0);
}

/// Access Token 프로바이더
final accessTokenProvider = Provider<String?>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session?.accessToken;
});

/// 로그아웃 및 상태 초기화
Future<void> signOut(WidgetRef ref) async {
  final supabase = ref.read(supabaseProvider);
  await supabase.auth.signOut();

  // 모든 캐시된 데이터 초기화
  ref.invalidate(myBrewLogsProvider);
  ref.invalidate(favoriteBrewLogsProvider);
  ref.invalidate(guidesProvider);
  ref.invalidate(featuredGuidesProvider);
  ref.invalidate(postsProvider);
  ref.invalidate(popularPostsProvider);
  ref.invalidate(articlesProvider);
}

/// 로그인 후 데이터 새로고침
void refreshAfterLogin(WidgetRef ref) {
  ref.invalidate(myBrewLogsProvider);
  ref.invalidate(favoriteBrewLogsProvider);
  ref.invalidate(guidesProvider);
  ref.invalidate(featuredGuidesProvider);
  ref.invalidate(postsProvider);
  ref.invalidate(popularPostsProvider);
  ref.invalidate(articlesProvider);
}
