import 'package:flutter/material.dart';

class AppTheme {
  static const purple = Color(0xFF7C3AED);
  static const deepPurple = Color(0xFF4C1D95);
  static const lightPurple = Color(0xFFEDE9FE);
  static const softLavender = Color(0xFFF5F3FF);
  static const pink = Color(0xFFEC4899);
  static const teal = Color(0xFF14B8A6);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const darkText = Color(0xFF18181B);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: purple),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: softLavender,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: purple, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A0E3D),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF2E1A66),
          indicatorColor: purple,
          height: 68,
          labelTextStyle: WidgetStatePropertyAll(
            const TextStyle(fontSize: 11, color: Colors.white),
          ),
          iconTheme: const WidgetStatePropertyAll(
            IconThemeData(color: Colors.white),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF08050F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF0D0916),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
}
