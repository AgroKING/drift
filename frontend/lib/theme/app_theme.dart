import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _background = Color(0xFF0F1117);
  static const Color _surface = Color(0xFF1A1D27);
  static const Color _textPrimary = Color(0xFFF1F5F9);
  static const Color _textSecondary = Color(0xFF94A3B8);

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _background,
    colorScheme: const ColorScheme.dark(
      surface: _surface,
      surfaceContainer: Color(0xFF1A1D27),

      onSurface: _textPrimary, 
      onSurfaceVariant: _textSecondary,

      primary: Color(0xFFF97316),
      error: Color(0xFFEF4444), 
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: _textPrimary,
      displayColor: _textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _background,
      foregroundColor: _textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: _surface,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.06),
      thickness: 1,
      space: 1,
    ),
  );
}
