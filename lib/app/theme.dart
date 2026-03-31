import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Dark theme ──────────────────────────────────────────────────────────────
  static const bg = Color(0xFF0A0A0A);
  static const bgCard = Color(0xFF111111);
  static const bgElevated = Color(0xFF1A1A1A);
  static const bgInput = Color(0xFF222222);
  static const bgOverlay = Color(0xFF2A2A2A);

  // Accent = pure white in dark mode (maximum contrast, zero colour)
  static const accent = Color(0xFFFFFFFF);
  static const accentDim = Color(0x14FFFFFF);    // 8% white
  static const accentMuted = Color(0x80FFFFFF);  // 50% white

  // Functional-only colours — workout UI, readiness, charts
  static const positive = Color(0xFF22C55E);
  static const positiveD = Color(0x1A22C55E);
  static const warning = Color(0xFFEAB308);
  static const warningDim = Color(0x1AEAB308);
  static const danger = Color(0xFFEF4444);
  static const dangerDim = Color(0x1AEF4444);

  // Legacy functional aliases — kept for workout/history/progress screens
  static const warm = Color(0xFFEAB308);
  static const warmDim = Color(0x1AEAB308);
  static const coral = Color(0xFFEF4444);
  static const coralDim = Color(0x1AEF4444);
  static const sky = Color(0xFF60A5FA);
  static const skyDim = Color(0x1A60A5FA);
  static const success = Color(0xFF22C55E);
  static const successDim = Color(0x1A22C55E);

  // Legacy dim aliases
  static const accentBright = Color(0xFFFFFFFF);
  static const accentText = Color(0xFFB0B0B0);
  static const borderHover = Color(0x29FFFFFF);

  // Text
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFF808080);
  static const textTertiary = Color(0xFF404040);
  static const textDisabled = Color(0xFF2A2A2A);
  static const textInverse = Color(0xFF0A0A0A);

  // Borders — hairline only
  static const border = Color(0x14FFFFFF);        // 8%
  static const borderStrong = Color(0x29FFFFFF);  // 16%
  static const borderSubtle = Color(0x0AFFFFFF);  // 4%
  static const borderAccent = borderStrong;       // legacy alias

  // ── Light theme ─────────────────────────────────────────────────────────────
  static const bgLight = Color(0xFFFFFFFF);
  static const bgCardLight = Color(0xFFFAFAFA);
  static const bgElevatedLight = Color(0xFFF2F2F2);
  static const bgInputLight = Color(0xFFEBEBEB);

  static const accentLight = Color(0xFF0A0A0A);
  static const accentDimLight = Color(0x0F0A0A0A);

  static const textPrimaryLight = Color(0xFF0A0A0A);
  static const textSecondaryLight = Color(0xFF6B6B6B);
  static const textTertiaryLight = Color(0xFFADADAD);
  static const textInverseLight = Color(0xFFF5F5F5);

  static const borderLight = Color(0x140A0A0A);        // 8%
  static const borderStrongLight = Color(0x290A0A0A);  // 16%

  // ── Shadows (monochrome) ────────────────────────────────────────────────────
  static final cardShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.24),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.10),
      blurRadius: 4,
      spreadRadius: 0,
      offset: const Offset(0, 1),
    ),
  ];

  static final subtleShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.14),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];

  static final accentShadow = subtleShadow; // alias kept for compat

  // Legacy glow aliases — kept for workout completion/progress screens
  static final indigoGlow = subtleShadow;
  static final fireGlow = subtleShadow;
  static final cardGlow = cardShadow;
  static final warmShadow = subtleShadow;

  // ── Gradients (monochrome in B&W system) ────────────────────────────────────
  static const subtleGradient = LinearGradient(
    colors: [Color(0x0AFFFFFF), Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Legacy gradient aliases — neutral in new B&W system, kept for compat
  static const accentGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFCCCCCC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const heroGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFF888888)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const ambientGradient = LinearGradient(
    colors: [Color(0x05FFFFFF), Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const warmGradient = LinearGradient(
    colors: [Color(0xFFEAB308), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const skyGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const coralGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const splitGradient = accentGradient;
  static const fireGradient = warmGradient;

  // accentGlow as a Color (used directly as container background)
  static const accentGlow = Color(0x0AFFFFFF);

  // Animation tokens
  static const Curve smoothIn = Curves.easeInOutCubic;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 10;
  static const double base = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double section = 40;
  static const double hero = 52;
  static const double cozy = 14;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double pill = 20;
  static const double circle = 9999;
}

class AppAnimation {
  static const entranceDuration = Duration(milliseconds: 500);
  static const staggerDelay = Duration(milliseconds: 60);
  static const microDuration = Duration(milliseconds: 180);
  static const springCurve = Curves.easeOutCubic;
  static const bounceCurve = Curves.elasticOut;
}

class AppBlur {
  static const double navBar = 24.0;
  static const double sheet = 20.0;
  static const double card = 12.0;
}

class AppTextStyles {
  static TextStyle hero(Color color) => GoogleFonts.inter(
      fontSize: 52,
      fontWeight: FontWeight.w800,
      letterSpacing: -2.0,
      height: 1.0,
      color: color);

  static TextStyle displayLarge(Color color) => GoogleFonts.inter(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
      height: 1.1,
      color: color);

  static TextStyle display(Color color) => GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: color);

  static TextStyle headingLarge(Color color) => GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: color);

  static TextStyle heading(Color color) => GoogleFonts.inter(
      fontSize: 17, fontWeight: FontWeight.w700, color: color);

  static TextStyle subhead(Color color) => GoogleFonts.inter(
      fontSize: 15, fontWeight: FontWeight.w600, color: color);

  static TextStyle body(Color color) => GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w400, color: color);

  static TextStyle bodyStrong(Color color) => GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: color);

  static TextStyle caption(Color color) => GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.8,
      color: color);

  static TextStyle labelUppercase(Color color) => GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: color);

  static TextStyle micro(Color color) => GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: color);

  static TextStyle dataLarge(Color color) => GoogleFonts.inter(
      fontSize: 44,
      fontWeight: FontWeight.w800,
      letterSpacing: -1,
      color: color);

  static TextStyle dataMedium(Color color) => GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
      color: color);

  static TextStyle dataInline(Color color) => GoogleFonts.inter(
      fontSize: 18, fontWeight: FontWeight.w700, color: color);
}

/// Context extension for theme-aware colors.
extension AppThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get appBg => isDark ? AppColors.bg : AppColors.bgLight;
  Color get appBgCard => isDark ? AppColors.bgCard : AppColors.bgCardLight;
  Color get appBgElevated =>
      isDark ? AppColors.bgElevated : AppColors.bgElevatedLight;
  Color get appTextPrimary =>
      isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
  Color get appTextSecondary =>
      isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
  Color get appTextTertiary =>
      isDark ? AppColors.textTertiary : AppColors.textTertiaryLight;
  Color get appBorder => isDark ? AppColors.border : AppColors.borderLight;
  Color get appBorderStrong =>
      isDark ? AppColors.borderStrong : AppColors.borderStrongLight;
  Color get appAccent =>
      isDark ? AppColors.accent : AppColors.accentLight;
  Color get appAccentDim =>
      isDark ? AppColors.accentDim : AppColors.accentDimLight;

  // Legacy aliases kept so existing call-sites compile without changes
  Color get appAccentGlow => appAccentDim;
  Color get appBorderAccent => appBorderStrong;
}

ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.textInverse,
      primaryContainer: AppColors.accentDim,
      secondary: AppColors.textSecondary,
      onSecondary: AppColors.textInverse,
      error: AppColors.danger,
      onError: AppColors.textPrimary,
      surface: AppColors.bgCard,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.bgElevated,
      outline: AppColors.border,
      outlineVariant: AppColors.borderStrong,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bgLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accentLight,
      onPrimary: AppColors.textInverseLight,
      primaryContainer: AppColors.accentDimLight,
      secondary: AppColors.textSecondaryLight,
      onSecondary: AppColors.textInverseLight,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.bgCardLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.bgElevatedLight,
      outline: AppColors.borderLight,
      outlineVariant: AppColors.borderStrongLight,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
