import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';

/// PC 버전 데스크탑 레이아웃
/// Twitter 스타일 3컬럼 레이아웃: 좌측 네비게이션, 중앙 콘텐츠, 우측 사이드바
class DesktopLayout extends ConsumerWidget {
  final Widget child;
  final String currentPath;
  final Widget? rightSidebar; // 우측 사이드바 (선택적)

  const DesktopLayout({
    super.key,
    required this.child,
    required this.currentPath,
    this.rightSidebar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // 화면 크기에 따라 우측 사이드바 표시 여부 결정
    final showRightSidebar = screenWidth >= 1200;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Row(
        children: [
          // 좌측 네비게이션 레일 (고정 280px)
          _DesktopNavigationRail(currentPath: currentPath, user: user),

          // 중앙 메인 컨텐츠 영역
          Expanded(
            child: Column(
              children: [
                // 상단 헤더
                _DesktopHeader(),

                // 메인 컨텐츠
                Expanded(
                  child: Container(color: Colors.white, child: child),
                ),
              ],
            ),
          ),

          // 우측 사이드바 (1200px 이상에서만 표시)
          if (showRightSidebar)
            _DesktopRightSidebar(
              currentPath: currentPath,
              customContent: rightSidebar,
            ),
        ],
      ),
    );
  }
}

/// 데스크톱 상단 헤더 (웹 전용)
class _DesktopHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200, width: 1)),
      ),
      child: Row(
        children: [
          // 검색바
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '검색...',
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                  filled: true,
                  fillColor: AppColors.gray50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 글쓰기 버튼 (로그인 시에만)
          if (isLoggedIn) ...[
            ElevatedButton.icon(
              onPressed: () => _showCreateMenu(context),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('작성'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // 알림 아이콘
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.bell, size: 22),
            color: AppColors.gray600,
          ),
        ],
      ),
    );
  }

  void _showCreateMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 200,
        64,
        20,
        0,
      ),
      items: [
        PopupMenuItem(
          onTap: () =>
              Future.delayed(Duration.zero, () => context.push('/post/new')),
          child: Row(
            children: [
              const Icon(LucideIcons.edit3, size: 18),
              const SizedBox(width: 12),
              const Text('글쓰기'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () =>
              Future.delayed(Duration.zero, () => context.push('/recode/new')),
          child: Row(
            children: [
              const Icon(LucideIcons.coffee, size: 18),
              const SizedBox(width: 12),
              const Text('추출 기록'),
            ],
          ),
        ),
      ],
    );
  }
}

/// 데스크탑 네비게이션 레일
class _DesktopNavigationRail extends ConsumerWidget {
  final String currentPath;
  final dynamic user;

  const _DesktopNavigationRail({required this.currentPath, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.gray200, width: 1)),
      ),
      child: Column(
        children: [
          // 로고 헤더
          _buildHeader(context),

          const SizedBox(height: AppSpacing.lg),

          // 네비게이션 메뉴
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildNavItem(
                    context,
                    icon: LucideIcons.home,
                    label: '홈',
                    path: '/',
                    isSelected: currentPath == '/',
                  ),
                  _buildNavItem(
                    context,
                    icon: LucideIcons.bookOpen,
                    label: '가이드',
                    path: '/guide',
                    isSelected: currentPath.startsWith('/guide'),
                  ),
                  _buildNavItem(
                    context,
                    icon: LucideIcons.newspaper,
                    label: '매거진',
                    path: '/magazine',
                    isSelected: currentPath.startsWith('/magazine'),
                  ),
                  _buildNavItem(
                    context,
                    icon: LucideIcons.coffee,
                    label: '추출 기록',
                    path: '/recode',
                    isSelected: currentPath.startsWith('/recode'),
                  ),
                  _buildNavItem(
                    context,
                    icon: LucideIcons.shoppingBag,
                    label: '장비',
                    path: '/equipment',
                    isSelected:
                        currentPath.startsWith('/equipment') ||
                        currentPath.startsWith('/products'),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildNavItem(
                    context,
                    icon: LucideIcons.user,
                    label: '프로필',
                    path: '/profile',
                    isSelected: currentPath.startsWith('/profile'),
                  ),
                ],
              ),
            ),
          ),

          // 하단 프로필 영역
          _buildProfileSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray200, width: 1)),
      ),
      child: Row(
        children: [
          // 로고 이미지
          Image.asset(
            'assets/images/logo.png',
            height: 32,
            errorBuilder: (context, error, stackTrace) => const Icon(
              LucideIcons.coffee,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          // Hello 인사 (애니메이션)
          const _AnimatedHelloText(),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String path,
    required bool isSelected,
    bool isDisabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  context.go(path);
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.primary
                      : isDisabled
                      ? AppColors.gray400
                      : AppColors.gray600,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : isDisabled
                          ? AppColors.gray400
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isDisabled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '준비중',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.gray600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, WidgetRef ref) {
    if (user == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.gray200, width: 1)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.push('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '로그인',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray200, width: 1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/profile'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.username?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username ?? '사용자',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.email ?? '',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: AppColors.gray500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 우측 사이드바 (광고 섹션)
class _DesktopRightSidebar extends StatelessWidget {
  final String currentPath;
  final Widget? customContent;

  const _DesktopRightSidebar({required this.currentPath, this.customContent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border(left: BorderSide(color: AppColors.gray200, width: 1)),
      ),
      child: Column(
        children: [
          // 상단 여백 (헤더와 맞춤)
          const SizedBox(height: 64),

          // 광고 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: customContent ?? _buildAdContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 광고 배너 1
        _AdBanner(
          title: 'BagIn Premium',
          subtitle: '무제한 추출 기록 저장',
          backgroundColor: AppColors.coffee,
          onTap: () {},
        ),

        const SizedBox(height: 16),

        // 광고 배너 2
        _AdBanner(
          title: '커피 장비 할인',
          subtitle: '최대 30% 할인 중',
          backgroundColor: AppColors.primaryDark,
          icon: LucideIcons.shoppingBag,
          onTap: () => context.push('/equipment'),
        ),

        const SizedBox(height: 16),

        // 추천 로스터리
        _AdCard(
          label: '추천',
          title: '이달의 로스터리',
          description: '프릳츠 커피 컴퍼니',
          imageIcon: LucideIcons.store,
          onTap: () {},
        ),

        const SizedBox(height: 16),

        // 앱 다운로드
        _AdCard(
          label: '모바일',
          title: 'BagIn 앱 다운로드',
          description: 'iOS & Android',
          imageIcon: LucideIcons.smartphone,
          onTap: () {},
        ),

        const SizedBox(height: 24),

        // 푸터
        _SidebarFooter(),
      ],
    );
  }
}

/// 광고 배너
class _AdBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final IconData? icon;
  final VoidCallback onTap;

  const _AdBanner({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 광고 카드
class _AdCard extends StatelessWidget {
  final String label;
  final String title;
  final String description;
  final IconData imageIcon;
  final VoidCallback onTap;

  const _AdCard({
    required this.label,
    required this.title,
    required this.description,
    required this.imageIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(imageIcon, size: 24, color: AppColors.gray600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 사이드바 푸터
class _SidebarFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _FooterLink(label: '이용약관', onTap: () {}),
            _FooterLink(label: '개인정보처리방침', onTap: () {}),
            _FooterLink(label: '문의하기', onTap: () {}),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '© 2024 BagIn Coffee',
          style: AppTypography.caption.copyWith(color: AppColors.gray400),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: AppColors.gray500),
      ),
    );
  }
}

/// 애니메이션 Hello 텍스트 (시간대별 인사)
class _AnimatedHelloText extends StatefulWidget {
  const _AnimatedHelloText();

  @override
  State<_AnimatedHelloText> createState() => _AnimatedHelloTextState();
}

class _AnimatedHelloTextState extends State<_AnimatedHelloText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 18) return 'Good Afternoon ☕';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello!',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              _getGreeting(),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 빠른 도구 카드 (타이머, 비율 계산기 등)
class _QuickToolsCard extends StatelessWidget {
  const _QuickToolsCard();

  @override
  Widget build(BuildContext context) {
    return _SidebarCard(
      title: '빠른 도구',
      icon: LucideIcons.wrench,
      children: [
        _ToolButton(
          icon: LucideIcons.timer,
          label: '타이머',
          onTap: () => _showTimerDialog(context),
        ),
        _ToolButton(
          icon: LucideIcons.scale,
          label: '비율 계산기',
          onTap: () => _showRatioCalculator(context),
        ),
        _ToolButton(
          icon: LucideIcons.thermometer,
          label: '온도 변환',
          onTap: () => _showTempConverter(context),
        ),
      ],
    );
  }

  void _showTimerDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const _TimerDialog());
  }

  void _showRatioCalculator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _RatioCalculatorDialog(),
    );
  }

  void _showTempConverter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _TempConverterDialog(),
    );
  }
}

/// 타이머 다이얼로그
class _TimerDialog extends StatefulWidget {
  const _TimerDialog();

  @override
  State<_TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<_TimerDialog> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStop() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _seconds++);
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isRunning = false;
    });
  }

  String _formatTime() {
    final min = _seconds ~/ 60;
    final sec = _seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(LucideIcons.timer, size: 24),
          const SizedBox(width: 8),
          const Text('타이머'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(),
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w300,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _startStop,
                icon: Icon(
                  _isRunning ? LucideIcons.pause : LucideIcons.play,
                  size: 18,
                ),
                label: Text(_isRunning ? '정지' : '시작'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning
                      ? AppColors.gray600
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(LucideIcons.rotateCcw, size: 18),
                label: const Text('리셋'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}

/// 비율 계산기 다이얼로그
class _RatioCalculatorDialog extends StatefulWidget {
  const _RatioCalculatorDialog();

  @override
  State<_RatioCalculatorDialog> createState() => _RatioCalculatorDialogState();
}

class _RatioCalculatorDialogState extends State<_RatioCalculatorDialog> {
  final _coffeeController = TextEditingController(text: '18');
  double _ratio = 16.0;
  double _water = 288;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _coffeeController.dispose();
    super.dispose();
  }

  void _calculate() {
    final coffee = double.tryParse(_coffeeController.text) ?? 0;
    setState(() {
      _water = coffee * _ratio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(LucideIcons.scale, size: 24),
          const SizedBox(width: 8),
          const Text('비율 계산기'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 원두량 입력
          TextField(
            controller: _coffeeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '원두량 (g)',
              border: OutlineInputBorder(),
              suffixText: 'g',
            ),
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 16),

          // 비율 슬라이더
          Text('비율: 1:${_ratio.toStringAsFixed(1)}'),
          Slider(
            value: _ratio,
            min: 10,
            max: 20,
            divisions: 20,
            label: '1:${_ratio.toStringAsFixed(1)}',
            onChanged: (value) {
              setState(() => _ratio = value);
              _calculate();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1:10', style: AppTypography.caption),
              Text('1:20', style: AppTypography.caption),
            ],
          ),

          const SizedBox(height: 24),

          // 결과
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('필요한 물'),
                Text(
                  '${_water.toStringAsFixed(0)}ml',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}

/// 온도 변환 다이얼로그
class _TempConverterDialog extends StatefulWidget {
  const _TempConverterDialog();

  @override
  State<_TempConverterDialog> createState() => _TempConverterDialogState();
}

class _TempConverterDialogState extends State<_TempConverterDialog> {
  final _celsiusController = TextEditingController(text: '93');
  double _fahrenheit = 199.4;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _celsiusController.dispose();
    super.dispose();
  }

  void _calculate() {
    final celsius = double.tryParse(_celsiusController.text) ?? 0;
    setState(() {
      _fahrenheit = (celsius * 9 / 5) + 32;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(LucideIcons.thermometer, size: 24),
          const SizedBox(width: 8),
          const Text('온도 변환'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 섭씨 입력
          TextField(
            controller: _celsiusController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '섭씨 (°C)',
              border: OutlineInputBorder(),
              suffixText: '°C',
            ),
            onChanged: (_) => _calculate(),
          ),

          const SizedBox(height: 24),

          // 결과
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text('화씨 (°F)'),
                Text(
                  '${_fahrenheit.toStringAsFixed(1)}°F',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 추천 온도 가이드
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('추천 추출 온도', style: AppTypography.labelMedium),
                const SizedBox(height: 8),
                _TempGuideRow(label: '라이트 로스트', temp: '92-96°C'),
                _TempGuideRow(label: '미디엄 로스트', temp: '90-94°C'),
                _TempGuideRow(label: '다크 로스트', temp: '85-90°C'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}

class _TempGuideRow extends StatelessWidget {
  final String label;
  final String temp;

  const _TempGuideRow({required this.label, required this.temp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(
            temp,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 인기 게시물 아이템
class _PopularPostItem extends StatelessWidget {
  final String title;
  final String author;
  final int likes;
  final VoidCallback onTap;

  const _PopularPostItem({
    required this.title,
    required this.author,
    required this.likes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    author,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(
                  LucideIcons.heart,
                  size: 12,
                  color: AppColors.gray400,
                ),
                const SizedBox(width: 4),
                Text('$likes', style: AppTypography.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 가이드 아이템
class _GuideItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GuideItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.bookOpen,
                size: 18,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}

/// 사이드바 카드 컴포넌트
class _SidebarCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SidebarCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.gray600),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// 도구 버튼
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.gray600),
                const SizedBox(width: 10),
                Text(label, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 최근 기록 아이템
class _RecentLogItem extends StatelessWidget {
  final String method;
  final String bean;
  final double rating;
  final VoidCallback? onTap;

  const _RecentLogItem({
    required this.method,
    required this.bean,
    required this.rating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.coffee,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    bean,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.gray500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (rating > 0)
              Row(
                children: [
                  const Icon(LucideIcons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    rating.toStringAsFixed(1),
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
