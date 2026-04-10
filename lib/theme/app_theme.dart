import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light mode
  static const lightBg = Color(0xFFFDFDFD);
  static const lightText = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF666666);
  static const lightTextTertiary = Color(0xFF999999);
  static const lightBorder = Color(0xFFE5E5E5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceSecondary = Color(0xFFF5F5F5);

  // Dark mode
  static const darkBg = Color(0xFF0A0A0A);
  static const darkText = Color(0xFFF0F0F0);
  static const darkTextSecondary = Color(0xFFA0A0A0);
  static const darkTextTertiary = Color(0xFF666666);
  static const darkBorder = Color(0xFF2A2A2A);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkSurfaceSecondary = Color(0xFF222222);

  // Task balloon colors - Light
  static const lightWhite = Color(0xFFFFFFFF);
  static const lightGreen = Color(0xFFE0F2F1);
  static const lightYellow = Color(0xFFFFF9C4);
  static const lightRed = Color(0xFFFFCDD2);
  static const lightBlue = Color(0xFFE3F2FD);
  static const lightPink = Color(0xFFF8BBD0);

  // Task balloon colors - Dark
  static const darkWhite = Color(0xFF2A2A2A);
  static const darkGreen = Color(0xFF1B5E20);
  static const darkYellow = Color(0xFFF57F17);
  static const darkRed = Color(0xFFB71C1C);
  static const darkBlue = Color(0xFF0D47A1);
  static const darkPink = Color(0xFF880E4F);

  // Accent
  static const accent = Color(0xFF1A1A1A);
  static const accentDark = Color(0xFFF0F0F0);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightText,
        secondary: AppColors.lightTextSecondary,
        surface: AppColors.lightSurface,
        outline: AppColors.lightBorder,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: GoogleFonts.inter(
          color: AppColors.lightText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.lightText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: GoogleFonts.inter(
          color: AppColors.lightText,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.inter(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: GoogleFonts.inter(
          color: AppColors.lightTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.lightText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightText),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightText, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.lightTextSecondary),
        hintStyle: GoogleFonts.inter(color: AppColors.lightTextTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightText,
          foregroundColor: AppColors.lightBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightText,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkText,
        secondary: AppColors.darkTextSecondary,
        surface: AppColors.darkSurface,
        outline: AppColors.darkBorder,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: GoogleFonts.inter(
          color: AppColors.darkTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.darkText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkText, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.darkTextSecondary),
        hintStyle: GoogleFonts.inter(color: AppColors.darkTextTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkText,
          foregroundColor: AppColors.darkBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkText,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  static Color taskCardColor(String hex, bool isDark) {
    final map = isDark ? _darkColorMap : _lightColorMap;
    return map[hex.toLowerCase()] ?? _hexToColor(hex);
  }

  static const _lightColorMap = {
    '#ffffff': AppColors.lightWhite,
    '#e0f2f1': AppColors.lightGreen,
    '#fff9c4': AppColors.lightYellow,
    '#ffcdd2': AppColors.lightRed,
    '#e3f2fd': AppColors.lightBlue,
    '#f8bbd0': AppColors.lightPink,
  };

  static const _darkColorMap = {
    '#ffffff': AppColors.darkWhite,
    '#e0f2f1': AppColors.darkGreen,
    '#fff9c4': AppColors.darkYellow,
    '#ffcdd2': AppColors.darkRed,
    '#e3f2fd': AppColors.darkBlue,
    '#f8bbd0': AppColors.darkPink,
  };

  static Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return AppColors.lightWhite;
  }
}

class AppColorPresets {
  static const presets = [
    {'label': 'Blanco', 'light': '#ffffff', 'dark': '#ffffff'},
    {'label': 'Verde', 'light': '#e0f2f1', 'dark': '#e0f2f1'},
    {'label': 'Amarillo', 'light': '#fff9c4', 'dark': '#fff9c4'},
    {'label': 'Rojo', 'light': '#ffcdd2', 'dark': '#ffcdd2'},
    {'label': 'Azul', 'light': '#e3f2fd', 'dark': '#e3f2fd'},
    {'label': 'Rosa', 'light': '#f8bbd0', 'dark': '#f8bbd0'},
  ];

  static final randomPool = [
    '#e0f2f1',
    '#fff9c4',
    '#ffcdd2',
    '#e3f2fd',
    '#f8bbd0',
  ];
}
