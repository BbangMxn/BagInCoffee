import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/utils/page_transitions.dart';
import 'features/main/presentation/main_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/guide/presentation/guide_screen.dart';
import 'features/magazine/presentation/magazine_screen.dart';
import 'features/equipment/presentation/equipment_screen.dart';
import 'features/equipment/presentation/equipment_detail_screen.dart';
import 'features/equipment/presentation/product_list_screen.dart';
import 'features/equipment/presentation/product_detail_screen.dart';
import 'features/equipment/presentation/review_create_screen.dart';
import 'features/equipment/presentation/brand_list_screen.dart';
import 'features/equipment/presentation/brand_detail_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/profile/presentation/profile_edit_screen.dart';
import 'features/profile/presentation/settings_screen.dart';
import 'features/profile/presentation/user_profile_screen.dart';
import 'features/post/presentation/post_detail_screen.dart';
import 'features/post/presentation/post_create_screen.dart';
import 'features/guide/presentation/guide_detail_screen.dart';
import 'features/magazine/presentation/article_detail_screen.dart';
import 'features/recode/presentation/recode_screen.dart';
import 'features/recode/presentation/recode_detail_screen.dart';
import 'features/recode/presentation/recode_form_screen.dart';
import 'features/notification/presentation/notification_screen.dart';

/// 앱 라우터
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final session = ref.read(currentSessionProvider);
      final isLoggedIn = session != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      // 로그인한 상태에서 로그인/회원가입 페이지 접근 시
      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // 메인 (헤더 + 사이드바 + 하단 네비게이션)
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/guide',
            builder: (context, state) => const GuideScreen(),
          ),
          GoRoute(
            path: '/magazine',
            builder: (context, state) => const MagazineScreen(),
          ),
          GoRoute(
            path: '/recode',
            builder: (context, state) => const RecodeScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/equipment',
            builder: (context, state) => const EquipmentScreen(),
          ),
        ],
      ),

      // 인증 (독립 화면 - 레이아웃 없음)
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // 게시물
      GoRoute(
        path: '/post/new',
        pageBuilder: (context, state) => PageTransitions.slideTransition(
          child: const PostCreateScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/post/edit/:id',
        builder: (context, state) =>
            PostCreateScreen(postId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) =>
            PostDetailScreen(postId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/guide/:id',
        builder: (context, state) =>
            GuideDetailScreen(guideId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/article/:id',
        builder: (context, state) =>
            ArticleDetailScreen(articleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/equipment/:id',
        builder: (context, state) =>
            EquipmentDetailScreen(itemId: state.pathParameters['id']!),
      ),

      // 제품 데이터베이스 (BagInDB)
      GoRoute(
        path: '/products',
        builder: (context, state) {
          final categoryId = state.uri.queryParameters['category_id'];
          final brandId = state.uri.queryParameters['brand_id'];
          return ProductListScreen(categoryId: categoryId, brandId: brandId);
        },
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/products/:id/review/new',
        builder: (context, state) =>
            ReviewCreateScreen(productId: state.pathParameters['id']!),
      ),

      // 브랜드
      GoRoute(
        path: '/brands',
        builder: (context, state) => const BrandListScreen(),
      ),
      GoRoute(
        path: '/brands/:id',
        builder: (context, state) =>
            BrandDetailScreen(brandId: state.pathParameters['id']!),
      ),

      // 프로필 수정 & 설정
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // 다른 사용자 프로필
      GoRoute(
        path: '/user/:id',
        builder: (context, state) =>
            UserProfileScreen(userId: state.pathParameters['id']!),
      ),

      // Recode 상세/작성/수정
      GoRoute(
        path: '/recode/new',
        builder: (context, state) => const RecodeFormScreen(),
      ),
      GoRoute(
        path: '/recode/edit/:id',
        builder: (context, state) =>
            RecodeFormScreen(recodeId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/recode/:id',
        builder: (context, state) =>
            RecodeDetailScreen(recodeId: state.pathParameters['id']!),
      ),

      // 알림
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
  );
});

/// 앱 메인 위젯
class BagInCoffeeApp extends ConsumerWidget {
  const BagInCoffeeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BagIn Coffee',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
