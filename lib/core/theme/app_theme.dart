import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF2874F0),
    secondaryHeaderColor: const Color(0xFF1C1C1C),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'OpenSans',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1C1C1C),
        fontFamily: 'Montserrat',
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1C1C1C),
        fontFamily: 'Montserrat',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF1C1C1C),
        fontFamily: 'OpenSans',
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2874F0),
      secondary: Color(0xFFFF9F00),
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
  );
} 