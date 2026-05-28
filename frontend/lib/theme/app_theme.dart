import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _background = Color(0xFFF8F9FA);  // Off-white/cream
  static const Color _surface = Color(0xFFFFFFFF);     // Pure white
  static const Color _textPrimary = Color(0xFF0F172A); // Deep navy/slate
  static const Color _textSecondary = Color(0xFF64748B); // Muted slate-gray
  
  static const Color _review = Color(0xFFEF4444);      // Red
  static const Color _reply = Color(0xFFF97316);       // Orange
  static const Color _commitment = Color(0xFFEAB308);  // Amber
  static const Color _staleness = Color(0xFF3B82F6);   // Blue
  static const Color _drift = Color(0xFFA855F7);       // Purple

  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: _background,
    colorScheme: ColorScheme.light(
      surface: _surface,
      onSurface: _textPrimary,
      onSurfaceVariant: _textSecondary,
      primary: _reply,  // Using reply orange as primary
      error: _review,   // Using review red as error
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: _textPrimary,
      displayColor: _textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _surface,
      foregroundColor: _textPrimary,
      elevation: 1,
      scrolledUnderElevation: 2,
    ),
    cardTheme: const CardThemeData(
      color: _surface,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
    ),
    dividerTheme: DividerThemeData(
      color: _textSecondary.withValues(alpha: 0.15),
      thickness: 1,
      space: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _reply,
        foregroundColor: _surface,
      ),
    ),
  );
}