import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Uber 스타일 타이포그래피
class AppTypography {
  AppTypography._();

  static String get fontFamily => GoogleFonts.notoSansKr().fontFamily!;

  // ============================================
  // Display
  // ============================================
  static TextStyle get displayLarge => GoogleFonts.notoSansKr(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => GoogleFonts.notoSansKr(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get displaySmall => GoogleFonts.notoSansKr(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  // ============================================
  // Headline
  // ============================================
  static TextStyle get headlineLarge => GoogleFonts.notoSansKr(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.notoSansKr(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.15,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineSmall => GoogleFonts.notoSansKr(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.15,
    color: AppColors.textPrimary,
  );

  // ============================================
  // Title
  // ============================================
  static TextStyle get titleLarge => GoogleFonts.notoSansKr(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.notoSansKr(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => GoogleFonts.notoSansKr(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ============================================
  // Body
  // ============================================
  static TextStyle get bodyLarge => GoogleFonts.notoSansKr(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.notoSansKr(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.notoSansKr(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  // ============================================
  // Label
  // ============================================
  static TextStyle get labelLarge => GoogleFonts.notoSansKr(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.notoSansKr(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelSmall => GoogleFonts.notoSansKr(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  // ============================================
  // Button
  // ============================================
  static TextStyle get buttonLarge => GoogleFonts.notoSansKr(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.white,
  );

  static TextStyle get buttonMedium => GoogleFonts.notoSansKr(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.white,
  );

  static TextStyle get buttonSmall => GoogleFonts.notoSansKr(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.white,
  );

  // ============================================
  // Caption
  // ============================================
  static TextStyle get caption => GoogleFonts.notoSansKr(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textTertiary,
  );

  static TextStyle get overline => GoogleFonts.notoSansKr(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textTertiary,
  );
}
