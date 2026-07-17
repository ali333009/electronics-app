import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.gold,
        secondary: AppColors.goldLight,
        surface: AppColors.surfaceCard,
        error: AppColors.error,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textWhite,
      ),
      fontFamily: GoogleFonts.cairo().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.black.withValues(alpha: 0.04),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: const TextStyle(
          fontFamily: AppTypography.fontArabic,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceCard,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: Color(0xFFA1A1A6),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return AppColors.goldDark;
            return AppColors.gold;
          }),
          foregroundColor: WidgetStateProperty.all(AppColors.textWhite),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 54)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
          ),
          textStyle: WidgetStateProperty.all(AppTypography.labelLarge.copyWith(color: AppColors.textWhite)),
          elevation: WidgetStateProperty.all(0),
          overlayColor: WidgetStateProperty.all(AppColors.goldDark.withValues(alpha: 0.3)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceCard,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
        behavior: SnackBarBehavior.floating,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 1,
        shadowColor: AppColors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.gold;
          return AppColors.divider;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
      ),
    );
  }
}
