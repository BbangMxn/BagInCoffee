import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';

/// 하단 네비게이션 아이템
class _NavItem {
  final String label;
  final String href;
  final IconData icon;

  const _NavItem({required this.label, required this.href, required this.icon});
}

/// 앱 하단 네비게이션
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key});

  static const _loggedInItems = [
    _NavItem(label: '홈', href: '/', icon: LucideIcons.home),
    _NavItem(label: '가이드', href: '/guide', icon: LucideIcons.bookOpen),
    _NavItem(label: '매거진', href: '/magazine', icon: LucideIcons.newspaper),
    _NavItem(label: '레코드', href: '/recode', icon: LucideIcons.coffee),
    _NavItem(label: '프로필', href: '/profile', icon: LucideIcons.user),
  ];

  static const _publicItems = [
    _NavItem(label: '홈', href: '/', icon: LucideIcons.home),
    _NavItem(label: '가이드', href: '/guide', icon: LucideIcons.bookOpen),
    _NavItem(label: '매거진', href: '/magazine', icon: LucideIcons.newspaper),
    _NavItem(label: '레코드', href: '/recode', icon: LucideIcons.coffee),
    _NavItem(label: '로그인', href: '/login', icon: LucideIcons.user),
  ];

  int _getCurrentIndex(String location, List<_NavItem> items) {
    for (var i = 0; i < items.length; i++) {
      if (items[i].href == '/') {
        if (location == '/') return i;
      } else if (location.startsWith(items[i].href)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 통합 전역 Auth 상태 사용
    final authState = ref.watch(globalAuthStateProvider);
    final items = authState.isLoggedIn ? _loggedInItems : _publicItems;
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getCurrentIndex(location, items);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.bottomNavHeight,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _BottomNavItem(
                    item: items[i],
                    isSelected: currentIndex == i,
                    onTap: () => context.go(items[i].href),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color(0xFF5D4A3F)
        : const Color(0xFFA3A09A);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 20, color: color),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
