import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}

class AppColors {
  static const Color cream = Color(0xFFF5F0E8);
  static const Color sand = Color(0xFFE8DCCA);
  static const Color linen = Color(0xFFF0E8D8);
  static const Color parchment = Color(0xFFD4C4A8);
  static const Color wheat = Color(0xFFC8B48A);
  static const Color terracotta = Color(0xFFB85C38);
  static const Color burntSienna = Color(0xFFC17445);
  static const Color olive = Color(0xFF8B8B4E);
  static const Color slate = Color(0xFF5C6B7A);
  static const Color ink = Color(0xFF2C2C2C);
  static const Color charcoal = Color(0xFF3D3530);
  static const Color success = Color(0xFF5E8A47);
  static const Color warning = Color(0xFFD4882A);
  static const Color error = Color(0xFFB84040);
  static const Color info = Color(0xFF4A7EA5);
  static const Color priorityLow = Color(0xFF6B9E6B);
  static const Color priorityMedium = Color(0xFFD4882A);
  static const Color priorityHigh = Color(0xFFB86040);
  static const Color priorityUrgent = Color(0xFFB84040);
  static const Color statusPending = Color(0xFF8B7355);
  static const Color statusInProgress = Color(0xFF4A7EA5);
  static const Color statusCompleted = Color(0xFF5E8A47);
}

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
    fontSize: 32, fontWeight: FontWeight.w700,
    color: AppColors.charcoal, letterSpacing: -0.5,
  );
  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
    fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.charcoal,
  );
  static TextStyle get headingLarge => GoogleFonts.playfairDisplay(
    fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.charcoal,
  );
  static TextStyle get headingMedium => GoogleFonts.cormorantGaramond(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.charcoal, letterSpacing: 0.2,
  );
  static TextStyle get bodyLarge => GoogleFonts.lato(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.charcoal, height: 1.6,
  );
  static TextStyle get bodyMedium => GoogleFonts.lato(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: const Color(0xFF3D3530), height: 1.5,
  );
  static TextStyle get labelLarge => GoogleFonts.lato(
    fontSize: 13, fontWeight: FontWeight.w600,
    letterSpacing: 1.2, color: AppColors.charcoal,
  );
  static TextStyle get caption => GoogleFonts.lato(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: const Color(0x993D3530), letterSpacing: 0.3,
  );
  static TextStyle get button => GoogleFonts.lato(
    fontSize: 14, fontWeight: FontWeight.w700,
    letterSpacing: 1.5, color: Colors.white,
  );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.terracotta,
      onPrimary: Colors.white,
      secondary: AppColors.burntSienna,
      onSecondary: Colors.white,
      surface: AppColors.cream,
      onSurface: AppColors.charcoal,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.linen,
    textTheme: GoogleFonts.latoTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.charcoal,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headingLarge,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cream,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.sand, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cream,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.parchment),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.parchment),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.terracotta, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: GoogleFonts.lato(color: const Color(0x993D3530)),
      hintStyle: GoogleFonts.lato(color: const Color(0x663D3530)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.terracotta,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.sand, thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.sand,
      selectedColor: const Color(0x26B85C38),
      labelStyle: GoogleFonts.lato(fontSize: 12, color: AppColors.charcoal),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}