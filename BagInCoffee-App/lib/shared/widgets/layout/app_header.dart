import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/stores/ui_store.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/auth_manager.dart';

/// 앱 헤더
class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 통합 전역 Auth 상태 사용
    final authState = ref.watch(globalAuthStateProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // 햄버거 메뉴
                IconButton(
                  onPressed: () => openSidebar(ref),
                  icon: const Icon(LucideIcons.menu, size: 20),
                  color: AppColors.gray500,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),

                // 로고 - 아날로그 매거진 스타일
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Text(
                    'BagINcoffee',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppColors.gray900,
                    ),
                  ),
                ),

                const Spacer(),

                // 알림 or 로그인
                if (authState.isLoggedIn)
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: Stack(
                      children: [
                        const Icon(LucideIcons.bell, size: 20),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    color: AppColors.gray500,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  )
                else
                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('로그인'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
