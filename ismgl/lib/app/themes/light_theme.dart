import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ismgl/app/themes/app_theme.dart';

class LightTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppTheme.primary,
      brightness: Brightness.light,
      primary: AppTheme.primary,
      secondary: AppTheme.secondary,
      error: AppTheme.error,
      background: AppTheme.backgroundLight,
      surface: AppTheme.cardLight,
    ),
    scaffoldBackgroundColor: AppTheme.backgroundLight,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: AppTheme.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: AppTheme.textPrimary),
    ),

    cardTheme: CardThemeData(
      color: AppTheme.cardLight,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.error),
      ),
      labelStyle: GoogleFonts.poppins(color: AppTheme.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      extendedTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}