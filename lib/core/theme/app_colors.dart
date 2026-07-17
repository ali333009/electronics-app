import 'package:flutter/material.dart';

class AppColors {
  // ========== Gold Primary ==========
  static const Color gold = Color(0xFFC9A86A);
  static const Color goldLight = Color(0xFFE8D5A3);
  static const Color goldDark = Color(0xFFA88B4A);
  static const Color goldBorder = Color(0xFFD4BC7E);

  // ========== Backgrounds ==========
  static const Color background = Color(0xFFF8F6F3);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF0ECE6);
  static const Color surfaceDark = Color(0xFF1A1A1A);

  // ========== Text on Light Bg ==========
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6E6E73);
  static const Color textMuted = Color(0xFFA1A1A6);

  // ========== Text on Dark Bg ==========
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textWhiteMuted = Color(0xFFB3B3B3);

  // legacy aliases
  static const Color textDark = textPrimary;
  static const Color textDarkSecondary = textSecondary;

  // ========== Borders & Dividers ==========
  static const Color border = Color(0xFFE5E0DA);
  static const Color divider = Color(0xFFE5E0DA);

  // ========== Status ==========
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFFCC00);

  // ========== Badges ==========
  static const Color badgeExclusive = gold;
  static const Color badgeBestSeller = gold;
  static const Color badgeNew = Color(0xFF0A84FF);
  static const Color badgeDiscount = error;

  // ========== Gradients ==========
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFC9A86A), Color(0xFFB8943F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient goldGradientVertical = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFC9A86A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient creamToWhite = LinearGradient(
    colors: [Color(0xFFF8F6F3), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ========== Misc ==========
  static const Color cardImageBg = Color(0xFFF0ECE6);
  static const Color backgroundLight = Color(0xFFF0ECE6);
  static const Color shimmerBase = Color(0xFFD4CFC8);
  static const Color shimmerHighlight = Color(0xFFE8E4DE);
  static const Color overlayDark = Color(0xCC000000);
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkCircle = Color(0xFF2A2A2A);
  static const Color lightCircle = Color(0xFFE8E4DE);
  static const Color darkContainer = Color(0xFF1A1A1A);
}
