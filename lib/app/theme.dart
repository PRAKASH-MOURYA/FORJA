import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark theme
  static const bg = Color(0xFF080810);
  static const bgCard = Color(0xFF111118);
  static const bgElevated = Color(0xFF18181F);
  static const bgInput = Color(0xFF1C1C26);
  static const accent = Color(0xFF6EE7B7);
  static const accentDim = Color(0x266EE7B7);
  static const accentGlow = Color(0x146EE7B7);
  static const warm = Color(0xFFF59E0B);
  static const warmDim = Color(0x26F59E0B);
  static const coral = Color(0xFFFB7185);
  static const coralDim = Color(0x26FB7185);
  static const sky = Color(0xFF38BDF8);
  static const skyDim = Color(0x2638BDF8);
  static const textPrimary = Color(0xFFF2F2F7);
  static const textSecondary = Color(0xFF8E8EA0);
  static const textTertiary = Color(0xFF48485C);
  static const border = Color(0x12FFFFFF);
  static const borderHover = Color(0x22FFFFFF);
  static const borderAccent = Color(0x336EE7B7);

  // Light theme
  static const bgLight = Color(0xFFF8F8FC);
  static const bgCardLight = Color(0xFFFFFFFF);
  static const bgElevatedLight = Color(0xFFF0F0F6);
  static const bgInputLight = Color(0xFFEEEEF4);
  static const accentLight = Color(0xFF059669);
  static const accentDimLight = Color(0x1A059669);
  static const warmLight = Color(0xFFD97706);
  static const coralLight = Color(0xFFE11D48);
  static const skyLight = Color(0xFF0284C7);
  static const textPrimaryLight = Color(0xFF0A0A0F);
  static const textSecondaryLight = Color(0xFF6B6B80);
  static const textTertiaryLight = Color(0xFF9999AD);
  static const borderLight = Color(0x0F000000);

  static const accentGradient = LinearGradient(
    colors: [Color(0xFF6EE7B7), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroGradient = LinearGradient(
    colors: [Color(0xFF6EE7B7), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const ambientGradient = LinearGradient(
    colors: [Color(0x0D6EE7B7), Color(0x003B82F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final accentShadow = [
    BoxShadow(
      color: accent.withValues(alpha: 0.28),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
  ];

  static final warmShadow = [
    BoxShadow(
      color: warm.withValues(alpha: 0.3),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 3),
    ),
  ];

  static final cardShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.28),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.12),
      blurRadius: 4,
      spreadRadius: 0,
      offset: const Offset(0, 1),
    ),
  ];

  static final subtleShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.16),
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 3),
    ),
  ];
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

ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.sky,
      error: AppColors.coral,
      surface: AppColors.bgCard,
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
      secondary: AppColors.skyLight,
      error: AppColors.coralLight,
      surface: AppColors.bgCardLight,
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
