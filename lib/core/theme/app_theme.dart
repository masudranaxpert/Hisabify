import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Orange palette
  static const primary = Color(0xFFF97316);
  static const primaryLight = Color(0xFFFB923C);
  static const primaryDark = Color(0xFFEA580C);

  // Status
  static const income = Color(0xFF22C55E);
  static const incomeLight = Color(0x2622C55E);
  static const expense = Color(0xFFEF4444);
  static const expenseLight = Color(0x26EF4444);

  // Category colors
  static const categoryFood = Color(0xFFEF4444);
  static const categoryTransport = Color(0xFFF59E0B);
  static const categoryEntertainment = Color(0xFFEC4899);
  static const categoryShopping = Color(0xFF8B5CF6);
  static const categoryBills = Color(0xFF06B6D4);
  static const categoryHealth = Color(0xFF22C55E);
  static const categoryEducation = Color(0xFF3B82F6);
  static const categorySalary = Color(0xFF22C55E);
  static const categoryFreelance = Color(0xFFF97316);
  static const categoryInvestment = Color(0xFFF59E0B);
  static const categoryGift = Color(0xFFEC4899);
  static const categoryOther = Color(0xFF6B7280);
}

class AppTheme {
  // ========== DARK THEME ==========
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: const Color(0xFF1C1917),
        onSurface: const Color(0xFFFAFAF9),
        surfaceContainerHighest: const Color(0xFF271E17),
        outline: const Color(0x26F97316),
      ),
      scaffoldBackgroundColor: const Color(0xFF0C0A09),
      cardColor: const Color(0xFF1C1410),
      dividerColor: const Color(0x26F97316),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0C0A09),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFFAFAF9),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1C1917),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFF78716C),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C1917),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x26F97316)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x26F97316)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF78716C)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ========== LIGHT THEME ==========
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: const Color(0xFFFFF7ED),
        onSurface: const Color(0xFF1C1917),
        surfaceContainerHighest: const Color(0xFFFFF7ED),
        outline: const Color(0x33F97316),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFBF5),
      cardColor: Colors.white,
      dividerColor: const Color(0x33F97316),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1C1917),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFFA8A29E),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFF7ED),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x33F97316)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x33F97316)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFFA8A29E)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
