import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../shared/widgets/layout/layout.dart';
import '../../../shared/widgets/layout/desktop_layout.dart';
import '../../../core/theme/app_colors.dart';

/// 반응형 브레이크포인트
const double _kDesktopBreakpoint = 1024;

/// 메인 화면 (헤더 + 사이드바 + 하단 네비게이션)
/// PC/웹에서는 좌측 네비게이션, 모바일에서는 하단 네비게이션 표시
class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // PC/웹 또는 화면이 큰 경우 데스크탑 레이아웃 사용
        final isDesktop = constraints.maxWidth >= _kDesktopBreakpoint;

        if (isDesktop) {
          return DesktopLayout(
            currentPath: GoRouterState.of(context).matchedLocation,
            child: child,
          );
        }

        // 모바일 레이아웃 (기존)
        return Scaffold(
          body: Stack(
            children: [
              // 메인 콘텐츠
              Column(
                children: [
                  const AppHeader(),
                  Expanded(child: child),
                ],
              ),
              // 사이드바 (오버레이)
              const AppSidebar(),
            ],
          ),
          floatingActionButton: _shouldShowFAB(context)
              ? FloatingActionButton(
                  onPressed: () => _showCreateMenu(context),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  child: const Icon(LucideIcons.plus, size: 28),
                )
              : null,
          bottomNavigationBar: const AppBottomNav(),
        );
      },
    );
  }

  /// FAB을 표시할지 여부 결정
  bool _shouldShowFAB(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    // 메인 탭 페이지에서만 표시
    const mainRoutes = [
      '/',
      '/guide',
      '/magazine',
      '/recode',
      '/profile',
      '/equipment',
    ];

    return mainRoutes.contains(location);
  }

  /// 작성 메뉴 표시 (기록하기 / 글쓰기)
  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 기록하기
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.coffee,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                title: const Text(
                  '추출 기록하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  '커피 추출 과정을 기록하세요',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/recode/new');
                },
              ),

              const Divider(height: 1),

              // 글쓰기
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.edit3,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                title: const Text(
                  '글쓰기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  '커피에 대한 이야기를 공유하세요',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/post/new');
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
