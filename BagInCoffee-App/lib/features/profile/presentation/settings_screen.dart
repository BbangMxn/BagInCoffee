import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../api/api.dart';

/// 설정 화면 (Uber 디자인)
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Map<String, dynamic> _notificationSettings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await notificationsApi.getSettings();
      setState(() {
        _notificationSettings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateNotificationSetting(String key, bool value) async {
    setState(() {
      _notificationSettings[key] = value;
    });

    try {
      await notificationsApi.updateSettings({key: value});
    } catch (e) {
      // 실패시 원래대로 복구
      setState(() {
        _notificationSettings[key] = !value;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('설정 저장 실패', style: GoogleFonts.inter()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '설정',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        children: [
          // 알림 설정
          _SectionHeader(title: '알림'),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _SwitchTile(
              title: '좋아요 알림',
              subtitle: '내 게시물에 좋아요가 달릴 때',
              value: _notificationSettings['likes'] ?? true,
              onChanged: (value) => _updateNotificationSetting('likes', value),
            ),
            _SwitchTile(
              title: '댓글 알림',
              subtitle: '내 게시물에 댓글이 달릴 때',
              value: _notificationSettings['comments'] ?? true,
              onChanged: (value) =>
                  _updateNotificationSetting('comments', value),
            ),
            _SwitchTile(
              title: '리뷰 알림',
              subtitle: '새로운 리뷰 관련 알림',
              value: _notificationSettings['reviews'] ?? true,
              onChanged: (value) =>
                  _updateNotificationSetting('reviews', value),
            ),
            _SwitchTile(
              title: '공지사항',
              subtitle: '중요한 업데이트 및 공지사항',
              value: _notificationSettings['announcements'] ?? true,
              onChanged: (value) =>
                  _updateNotificationSetting('announcements', value),
            ),
          ],

          const Divider(height: 32, thickness: 8, color: AppColors.gray100),

          // 계정
          _SectionHeader(title: '계정'),
          _MenuTile(
            icon: LucideIcons.user,
            title: '프로필 수정',
            onTap: () => context.push('/profile/edit'),
          ),
          _MenuTile(
            icon: LucideIcons.shield,
            title: '개인정보 처리방침',
            onTap: () {
              // TODO: 개인정보 처리방침 페이지
            },
          ),
          _MenuTile(
            icon: LucideIcons.fileText,
            title: '서비스 이용약관',
            onTap: () {
              // TODO: 서비스 이용약관 페이지
            },
          ),

          const Divider(height: 32, thickness: 8, color: AppColors.gray100),

          // 앱 정보
          _SectionHeader(title: '앱 정보'),
          _MenuTile(
            icon: LucideIcons.info,
            title: '버전',
            trailing: Text(
              '1.0.0',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          _MenuTile(
            icon: LucideIcons.mail,
            title: '문의하기',
            onTap: () {
              // TODO: 문의하기 기능
            },
          ),

          const Divider(height: 32, thickness: 8, color: AppColors.gray100),

          // 로그아웃 & 탈퇴
          _MenuTile(
            icon: LucideIcons.logOut,
            title: '로그아웃',
            textColor: AppColors.error,
            onTap: () => _showLogoutDialog(),
          ),
          _MenuTile(
            icon: LucideIcons.trash2,
            title: '회원 탈퇴',
            textColor: AppColors.error,
            onTap: () => _showDeleteAccountDialog(),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '로그아웃',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '정말 로그아웃 하시겠습니까?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(supabaseProvider).auth.signOut();
              ref.read(userProfileProvider.notifier).clear();
              if (mounted) {
                context.go('/');
              }
            },
            child: Text(
              '로그아웃',
              style: GoogleFonts.inter(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '회원 탈퇴',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '정말 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '회원 탈퇴 기능은 준비 중입니다',
                    style: GoogleFonts.inter(),
                  ),
                ),
              );
            },
            child: Text('탈퇴', style: GoogleFonts.inter(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// 섹션 헤더
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// 메뉴 타일
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? textColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.textColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? AppColors.textPrimary;

    return ListTile(
      leading: Icon(icon, size: 22, color: color),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing:
          trailing ??
          (onTap != null
              ? Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: AppColors.gray400,
                )
              : null),
      onTap: onTap,
    );
  }
}

/// 스위치 타일
class _SwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}
