import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';

/// 회원가입 화면
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 완료되었습니다. 이메일을 확인해주세요.')),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 실패: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = kIsWeb && screenWidth >= 900;

    if (isDesktop) {
      return _buildDesktopLayout(context);
    }
    return _buildMobileLayout(context);
  }

  /// 데스크톱 레이아웃 (2컬럼)
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 좌측: 브랜딩 섹션
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.coffee,
                    AppColors.coffee.withValues(alpha: 0.85),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // 배경 패턴
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.05,
                      child: Image.asset(
                        'assets/images/coffee_pattern.png',
                        repeat: ImageRepeat.repeat,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    ),
                  ),
                  // 컨텐츠
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 로고
                          Image.asset(
                            'assets/images/logo_white.png',
                            height: 100,
                            errorBuilder: (_, __, ___) => Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                LucideIcons.coffee,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'BagIn Coffee',
                            style: GoogleFonts.inter(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '커피 여정을 시작하세요',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 48),
                          // 기능 소개
                          _buildFeatureItem(
                            icon: LucideIcons.edit3,
                            title: '추출 레시피 저장',
                            description: '나만의 완벽한 레시피를 기록하세요',
                          ),
                          const SizedBox(height: 20),
                          _buildFeatureItem(
                            icon: LucideIcons.trendingUp,
                            title: '성장 트래킹',
                            description: '시간이 지남에 따른 발전을 확인하세요',
                          ),
                          const SizedBox(height: 20),
                          _buildFeatureItem(
                            icon: LucideIcons.share2,
                            title: '레시피 공유',
                            description: '커뮤니티와 경험을 나누세요',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 우측: 회원가입 폼
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: _buildSignupForm(context, isDesktop: true),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 모바일 레이아웃
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              // 로고
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.coffee,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _buildSignupForm(context, isDesktop: false),
            ],
          ),
        ),
      ),
    );
  }

  /// 회원가입 폼 (공통)
  Widget _buildSignupForm(BuildContext context, {required bool isDesktop}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) ...[
            // 뒤로가기 버튼 (데스크톱)
            IconButton(
              onPressed: () => context.go('/'),
              icon: const Icon(LucideIcons.arrowLeft),
              style: IconButton.styleFrom(backgroundColor: AppColors.gray100),
            ),
            const SizedBox(height: 32),
          ],
          Text(
            '회원가입',
            style: isDesktop
                ? GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )
                : AppTypography.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '커피 여정을 시작하세요',
            style:
                (isDesktop
                        ? GoogleFonts.inter(fontSize: 15)
                        : AppTypography.bodyLarge)
                    .copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: isDesktop ? 32 : AppSpacing.xxxl),

          // 이메일 입력
          if (isDesktop)
            Text(
              '이메일',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          if (isDesktop) const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: isDesktop ? GoogleFonts.inter(fontSize: 15) : null,
            decoration: InputDecoration(
              labelText: isDesktop ? null : '이메일',
              hintText: 'example@email.com',
              prefixIcon: isDesktop
                  ? const Icon(LucideIcons.mail, size: 20)
                  : null,
              filled: isDesktop,
              fillColor: AppColors.gray50,
              border: isDesktop
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.gray200),
                    )
                  : null,
              enabledBorder: isDesktop
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.gray200),
                    )
                  : null,
              focusedBorder: isDesktop
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    )
                  : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력하세요';
              }
              if (!value.contains('@')) {
                return '올바른 이메일 형식이 아닙니다';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // 비밀번호 입력
          if (isDesktop)
            Text(
              '비밀번호',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          if (isDesktop) const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            style: isDesktop ? GoogleFonts.inter(fontSize: 15) : null,
            decoration: InputDecoration(
              labelText: isDesktop ? null : '비밀번호',
              hintText: '8자 이상 입력하세요',
              prefixIcon: isDesktop
                  ? const Icon(LucideIcons.lock, size: 20)
                  : null,
              filled: isDesktop,
              fillColor: AppColors.gray50,
              border: isDesktop
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.gray200),
                    )
                  : null,
              enabledBorder: isDesktop
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.gray200),
                    )
                  : null,
              focusedBorder: isDesktop
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    )
                  : null,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: isDesktop ? 20 : 24,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력하세요';
              }
              if (value.length < 8) {
                return '비밀번호는 8자 이상이어야 합니다';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // 비밀번호 확인
          if (isDesktop)
            Text(
              '비밀번호 확인',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          if (isDesktop) const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSignup(),
            style: isDesktop ? GoogleFonts.inter(fontSize: 15) : null,
            decoration: InputDecoration(
              labelText: isDesktop ? null : '비밀번호 확인',
              hintText: isDesktop ? '비밀번호를 다시 입력하세요' : null,
              prefixIcon: isDesktop
                  ? const Icon(LucideIcons.lock, size: 20)
                  : null,
              filled: isDesktop,
              fillColor: AppColors.gray50,
              border: isDesktop
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.gray200),
                    )
                  : null,
              enabledBorder: isDesktop
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.gray200),
                    )
                  : null,
              focusedBorder: isDesktop
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    )
                  : null,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? LucideIcons.eyeOff
                      : LucideIcons.eye,
                  size: isDesktop ? 20 : 24,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 다시 입력하세요';
              }
              if (value != _passwordController.text) {
                return '비밀번호가 일치하지 않습니다';
              }
              return null;
            },
          ),

          SizedBox(height: isDesktop ? 32 : AppSpacing.xxxl),

          // 회원가입 버튼
          SizedBox(
            width: double.infinity,
            height: isDesktop ? 52 : null,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignup,
              style: isDesktop
                  ? ElevatedButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    )
                  : null,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      '회원가입',
                      style: isDesktop
                          ? GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            )
                          : null,
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 로그인 링크
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '이미 계정이 있으신가요?',
                style:
                    (isDesktop
                            ? GoogleFonts.inter(fontSize: 14)
                            : AppTypography.bodyMedium)
                        .copyWith(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () => context.pushReplacement('/login'),
                child: Text(
                  '로그인',
                  style: isDesktop
                      ? GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
