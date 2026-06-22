import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor   = Color(0xFF212121);
  static const Color secondaryColor = Color(0xFF616161); 
  static const Color accentColor    = Color(0xFF00E5FF); 
  static const Color bgColor        = Color(0xFF121212);
  static const Color cardColor      = Color(0xFF1E1E1E); 
  static const Color textPrimary    = Color(0xFFFFFFFF); 
  static const Color textSecondary  = Color(0xFFB0B0B0); 

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: bgColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
     cardTheme: CardThemeData(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
      filled: true,
      fillColor: cardColor,
      labelStyle: const TextStyle(color: textSecondary),
    ),
  );
}