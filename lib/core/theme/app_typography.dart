import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const String fontArabic = 'Cairo';
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontArabic,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontArabic,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontArabic,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontArabic,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontArabic,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontArabic,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontArabic,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontArabic,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle price = TextStyle(
    fontFamily: fontArabic,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
  );

  static const TextStyle priceMuted = TextStyle(
    fontFamily: fontArabic,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: fontArabic,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontArabic,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle captionBold = TextStyle(
    fontFamily: fontArabic,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLargeBold = TextStyle(
    fontFamily: fontArabic,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
