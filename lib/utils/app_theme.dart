// lib/utils/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF2D9B83);
  static const Color primaryDark = Color(0xFF1E6E5C);
  static const Color primaryLight = Color(0xFF4DBDA0);
  static const Color accent = Color(0xFF5CE0C0);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFE53935);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color cardBg = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.notoSans(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.notoSans(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: GoogleFonts.notoSans(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class AppConstants {
  static const List<String> incomeCategories = [
    'Upwork',
    'Цалин',
    'Paypal',
    'Freelance',
    'Хөрөнгө оруулалт',
    'Бусад орлого',
  ];

  static const List<String> expenseCategories = [
    'Хоол хүнс',
    'Тээвэр',
    'Youtube',
    'Эрүүл мэнд',
    'Боловсрол',
    'Худалдан авалт',
    'Коммунал',
    'Бусад зарлага',
  ];

  static const Map<String, String> categoryIcons = {
    'Upwork': '💼',
    'Цалин': '💰',
    'Paypal': '💳',
    'Freelance': '🖥️',
    'Хөрөнгө оруулалт': '📈',
    'Хоол хүнс': '🍔',
    'Тээвэр': '🚗',
    'Youtube': '▶️',
    'Эрүүл мэнд': '🏥',
    'Боловсрол': '📚',
    'Худалдан авалт': '🛍️',
    'Коммунал': '🏠',
    'Бусад орлого': '💵',
    'Бусад зарлага': '📦',
  };
}
