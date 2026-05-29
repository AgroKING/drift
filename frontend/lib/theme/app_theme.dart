// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _background = Color(0xFFF8F9FA);  
  static const Color _surface = Color(0xFFFFFFFF);    
  static const Color _textPrimary = Color(0xFF0F172A); 
  static const Color _textSecondary = Color(0xFF64748B); 
  
  static const Color _review = Color(0xFFEF4444);      
  static const Color _reply = Color(0xFFF97316);       
  static const Color _commitment = Color(0xFFEAB308);  
  static const Color _staleness = Color(0xFF3B82F6);   
  static const Color _drift = Color(0xFFA855F7);       

  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: _background,
    colorScheme: ColorScheme.light(
      surface: _surface,
      onSurface: _textPrimary,
      onSurfaceVariant: _textSecondary,
      primary: _reply,  
      error: _review,  
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