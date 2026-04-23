import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ismgl/app/themes/app_theme.dart';

class DarkTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppTheme.primary,
      brightness: Brightness.dark,
      primary: AppTheme.secondary,
      secondary: AppTheme.accent,
      error: AppTheme.error,
      background: AppTheme.backgroundDark,
      surface: AppTheme.cardDark,
    ),
    scaffoldBackgroundColor: AppTheme.backgroundDark,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    cardTheme: CardThemeData(
      color: AppTheme.cardDark,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(color: AppTheme.textLight),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E293B),
      selectedItemColor: AppTheme.secondary,
      unselectedItemColor: AppTheme.textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppTheme.secondary,
      foregroundColor: Colors.white,
      extendedTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}