import 'package:flutter/material.dart';

/// FORJA Design System — Color Tokens
/// Mirrors the React/TypeScript ThemeContext exactly.
class AppColors {
  // ─── Dark theme (default) ────────────────────────────────────────────────

  /// Primary background: #0A0A0F
  static const darkBg = Color(0xFF0A0A0F);

  /// Card surface: #13131A
  static const darkBgCard = Color(0xFF13131A);

  /// Elevated card / table row: #1A1A24
  static const darkBgElevated = Color(0xFF1A1A24);

  /// Input background: #1E1E2A
  static const darkBgInput = Color(0xFF1E1E2A);

  /// Mint accent (primary CTA, highlights): #6EE7B7
  static const darkAccent = Color(0xFF6EE7B7);

  /// Mint at 15% opacity — pill / tag backgrounds
  static const darkAccentDim = Color(0x266EE7B7);

  /// Mint at 8% opacity — subtle glow / banner tint
  static const darkAccentGlow = Color(0x146EE7B7);

  /// Warm amber (readiness badge, timer): #F59E0B
  static const darkWarm = Color(0xFFF59E0B);

  /// Amber at 15% opacity
  static const darkWarmDim = Color(0x26F59E0B);

  /// Coral / pink (soreness, warnings): #FB7185
  static const darkCoral = Color(0xFFFB7185);

  /// Coral at 14% opacity
  static const darkCoralDim = Color(0x26FB7185);

  /// Sky blue (video, secondary info): #38BDF8
  static const darkSky = Color(0xFF38BDF8);

  /// Sky at 12% opacity
  static const darkSkyDim = Color(0x2638BDF8);

  /// Primary text: #F0F0F5
  static const darkTextPrimary = Color(0xFFF0F0F5);

  /// Secondary text / labels: #8888A0
  static const darkTextSecondary = Color(0xFF8888A0);

  /// Tertiary text / disabled: #55556A
  static const darkTextTertiary = Color(0xFF55556A);

  /// Separator / border — white at 6% opacity
  static const darkBorder = Color(0x0FFFFFFF);

  // ─── Light theme ─────────────────────────────────────────────────────────

  static const lightBg = Color(0xFFF8F8FC);
  static const lightBgCard = Color(0xFFFFFFFF);
  static const lightBgElevated = Color(0xFFF0F0F6);
  static const lightBgInput = Color(0xFFEEEEF4);
  static const lightAccent = Color(0xFF059669);
  static const lightAccentDim = Color(0x1A059669);
  static const lightAccentGlow = Color(0x0D059669);
  static const lightWarm = Color(0xFFD97706);
  static const lightCoral = Color(0xFFE11D48);
  static const lightSky = Color(0xFF0284C7);
  static const lightTextPrimary = Color(0xFF0A0A0F);
  static const lightTextSecondary = Color(0xFF6B6B80);
  static const lightTextTertiary = Color(0xFF9999AD);
  static const lightBorder = Color(0x0F000000);

  // ─── Gradients ───────────────────────────────────────────────────────────

  /// Primary CTA gradient — dark mode button fill
  static const accentGradient = LinearGradient(
    colors: [Color(0xFF6EE7B7), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Light mode CTA gradient
  static const accentGradientLight = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Spacing tokens (8-pt grid)
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Border-radius tokens
class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 100;
}

/// Typography scale — matches Inter weights used throughout
class AppTextStyle {
  static const String fontFamily = 'Inter';

  static TextStyle displayLg({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.2,
        color: color,
      );

  static TextStyle displayMd({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        height: 1.2,
        color: color,
      );

  static TextStyle titleLg({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle titleMd({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle bodyLg({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle bodyMd({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodySm({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle labelLg({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: color,
      );

  static TextStyle labelSm({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: color,
      );

  static TextStyle numericLg({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
        height: 1,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color,
      );
}
