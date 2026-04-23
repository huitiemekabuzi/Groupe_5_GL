import 'package:flutter/material.dart';
import 'package:ismgl/app/themes/light_theme.dart';
import 'package:ismgl/app/themes/dark_theme.dart';

class AppTheme {
  static ThemeData get lightTheme => LightTheme.theme;
  static ThemeData get darkTheme  => DarkTheme.theme;

  // Couleurs principales ISMGL
  static const Color primary      = Color(0xFF1E3A8A);
  static const Color secondary    = Color(0xFF3B82F6);
  static const Color accent       = Color(0xFF60A5FA);
  static const Color success      = Color(0xFF10B981);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color error        = Color(0xFFEF4444);
  static const Color info         = Color(0xFF6366F1);

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark  = Color(0xFF0F172A);
  static const Color cardLight       = Color(0xFFFFFFFF);
  static const Color cardDark        = Color(0xFF1E293B);

  static const Color textPrimary   = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight     = Color(0xFFCBD5E1);

  // Gradient principal
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Couleur info / secondaire manquante dans certaines vues
  static const Color surfaceVariant = Color(0xFFE2E8F0);
}