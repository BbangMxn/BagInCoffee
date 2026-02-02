import 'package:flutter/material.dart';

/// Uber 스타일 색상 시스템
class AppColors {
  AppColors._();

  // ============================================
  // Primary Colors (Uber Style - Black & White)
  // ============================================
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // ============================================
  // Gray Scale
  // ============================================
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // ============================================
  // Semantic Colors
  // ============================================
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF3D00);
  static const Color info = Color(0xFF2979FF);

  // ============================================
  // Background Colors
  // ============================================
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF7F7F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF5F5F5);

  // ============================================
  // Text Colors
  // ============================================
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF545454);
  static const Color textTertiary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Coffee Brown Text (포인트 색상)
  static const Color textBrown = Color(0xFF6F4E37);
  static const Color textBrownLight = Color(0xFF8B6F5C);

  // ============================================
  // Border Colors
  // ============================================
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color borderDark = Color(0xFFBDBDBD);

  // ============================================
  // Divider
  // ============================================
  static const Color divider = Color(0xFFEEEEEE);
  static const Color dividerDark = Color(0xFFE0E0E0);

  // ============================================
  // Overlay
  // ============================================
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // ============================================
  // Primary & Accent (Coffee Theme - Light Brown)
  // ============================================
  static const Color primary = Color(0xFFA0826D); // Light Brown
  static const Color primaryDark = Color(0xFF8B6F5C); // Darker Brown
  static const Color primaryLight = Color(0xFFBFA08A); // Lighter Brown
  static const Color accent = Color(0xFFA0826D); // Light Brown (alias)

  // Coffee-themed accent colors
  static const Color coffee = Color(0xFF6F4E37); // Coffee Brown
  static const Color coffeeLight = Color(0xFFA0826D); // Light Coffee
  static const Color coffeeCream = Color(0xFFD4B896); // Cream
}
