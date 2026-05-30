import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core surfaces
  static const Color background = Color(0xFF0F1117);
  static const Color surface = Color(0xFF181B23);
  static const Color surfaceElevated = Color(0xFF1E2230);
  static const Color surfaceOverlay = Color(0x0AFFFFFF); 

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Borders
  static const Color border = Color(0x14FFFFFF); 
  static const Color borderSubtle = Color(0x0AFFFFFF); 
  static const Color borderFocus = Color(0x29FFFFFF); 

  // Brand / accent
  static const Color accent = Color(0xFF0D9488);
  static const Color accentMuted = Color(0x260D9488); 
  static const Color accentBorder = Color(0x590D9488); 

  // Debt categories
  static const Color review = Color(0xFFEF4444);
  static const Color reply = Color(0xFFF97316);
  static const Color commitment = Color(0xFFEAB308);
  static const Color staleness = Color(0xFF3B82F6);
  static const Color drift = Color(0xFFA855F7);

  // Semantic
  static const Color scoreUp = Color(0xFFEF4444);
  static const Color scoreDown = Color(0xFF16A34A);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      primary: accent,
      error: error,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: border),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: borderSubtle,
      thickness: 1,
      space: 1,
    ),
  );
}