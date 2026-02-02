import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/stores/ui_store.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/auth_manager.dart';
import '../../../core/providers/user_provider.dart';

/// 사이드바 메뉴 아이템
class _MenuItem {
  final String label;
  final String href;
  final IconData icon;
  final bool disabled;

  const _MenuItem({
    required this.label,
    required this.href,
    required this.icon,
    this.disabled = false,
  });
}

/// 사이드바 메뉴 섹션
class _MenuSection {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});
}

/// 앱 사이드바
class AppSidebar extends ConsumerStatefulWidget {
  const AppSidebar({super.key});

  @override
  ConsumerState<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends ConsumerState<AppSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  static const _loggedInSections = [
    _MenuSection(
      title: '메인',
      items: [
        _MenuItem(label: '홈', href: '/', icon: LucideIcons.home),
        _MenuItem(label: '내 프로필', href: '/profile', icon: LucideIcons.user),
        _MenuItem(label: '글 작성', href: '/post/new', icon: LucideIcons.plus),
      ],
    ),
    _MenuSection(
      title: '장비',
      items: [
        _MenuItem(label: '전체 장비', href: '/equipment', icon: LucideIcons.coffee),
        _MenuItem(label: '브랜드별', href: '/brands', icon: LucideIcons.tag),
      ],
    ),
    _MenuSection(
      title: '기타',
      items: [
        _MenuItem(
          label: '중고 거래',
          href: '/marketplace',
          icon: LucideIcons.shoppingCart,
          disabled: true,
        ),
        _MenuItem(label: '설정', href: '/settings', icon: LucideIcons.settings),
      ],
    ),
  ];

  static const _publicSections = [
    _MenuSection(
      title: '메인',
      items: [
        _MenuItem(label: '홈', href: '/', icon: LucideIcons.home),
        _MenuItem(label: '가이드', href: '/guide', icon: LucideIcons.bookOpen),
        _MenuItem(label: '매거진', href: '/magazine', icon: LucideIcons.newspaper),
      ],
    ),
    _MenuSection(
      title: '장비',
      items: [
        _MenuItem(label: '전체 장비', href: '/equipment', icon: LucideIcons.coffee),
        _MenuItem(label: '브랜드별', href: '/brands', icon: LucideIcons.tag),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 통합 전역 Auth 상태 사용
    final authState = ref.watch(globalAuthStateProvider);
    final isOpen = ref.watch(sidebarOpenProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = authState.isLoggedIn ? profileAsync.valueOrNull : null;

    final sections = authState.isLoggedIn ? _loggedInSections : _publicSections;

    return Stack(
      children: [
        // 오버레이
        if (isOpen)
          GestureDetector(
            onTap: () => closeSidebar(ref),
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),

        // 사이드바
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          left: isOpen ? 0 : -280,
          top: 0,
          bottom: 0,
          width: 280,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: SafeArea(
              right: false,
              bottom: false,
              child: Column(
                children: [
                  // 헤더
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: 28,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox(width: 8),
                            AnimatedBuilder(
                              animation: _waveAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _waveAnimation.value,
                                  child: child,
                                );
                              },
                              child: Text(
                                'Hello!',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => closeSidebar(ref),
                          icon: const Icon(LucideIcons.x, size: 22),
                          color: AppColors.gray600,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: AppColors.gray200),

                  // 프로필 섹션
                  if (authState.isLoggedIn && authState.user != null)
                    InkWell(
                      onTap: () {
                        closeSidebar(ref);
                        context.push('/profile');
                      },
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.gray50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary,
                              backgroundImage: profile?.avatarUrl != null
                                  ? NetworkImage(profile!.avatarUrl!)
                                  : null,
                              child: profile?.avatarUrl == null
                                  ? Text(
                                      authState.user!.email
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          'U',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile?.username ??
                                        authState.user!.email?.split('@')[0] ??
                                        '사용자',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    authState.user!.email ?? '',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 18,
                              color: AppColors.gray400,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            closeSidebar(ref);
                            context.push('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '로그인',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 메뉴
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      children: [
                        for (var i = 0; i < sections.length; i++) ...[
                          if (i > 0) const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              sections[i].title.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textTertiary,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          for (final item in sections[i].items)
                            _SidebarMenuItem(
                              item: item,
                              onTap: () {
                                if (item.disabled) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('추후 개발 예정입니다.'),
                                    ),
                                  );
                                } else {
                                  closeSidebar(ref);
                                  context.push(item.href);
                                }
                              },
                            ),
                        ],

                        // 로그아웃
                        if (authState.isLoggedIn) ...[
                          const Divider(height: 16, indent: 8, endIndent: 8),
                          _SidebarMenuItem(
                            item: const _MenuItem(
                              label: '로그아웃',
                              href: '',
                              icon: LucideIcons.logOut,
                            ),
                            isDestructive: true,
                            onTap: () async {
                              closeSidebar(ref);

                              try {
                                await getAuthManager(ref).signOut();

                                // 모든 auth 관련 provider 강제 새로고침
                                ref.invalidate(authStateProvider);
                                ref.invalidate(currentSessionProvider);
                                ref.invalidate(currentUserProvider);
                                ref.invalidate(globalAuthStateProvider);

                                // 약간의 지연 후 홈으로 이동
                                await Future.delayed(
                                  const Duration(milliseconds: 100),
                                );

                                if (context.mounted) {
                                  context.go('/');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('로그아웃 실패: $e'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 푸터
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Text(
                      '© 2025 BagInCoffee',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SidebarMenuItem extends StatelessWidget {
  final _MenuItem item;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SidebarMenuItem({
    required this.item,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : item.disabled
        ? AppColors.textSecondary
        : AppColors.textPrimary;
    final iconColor = isDestructive
        ? AppColors.error
        : item.disabled
        ? AppColors.gray400
        : AppColors.gray600;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(item.icon, size: 20, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            if (item.disabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '준비중',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
