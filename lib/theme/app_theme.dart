import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF1A73E8);
  static const successColor = Color(0xFF1D9E75);
  static const warningColor = Color(0xFFEF9F27);
  static const dangerColor = Color(0xFFE24B4A);

  static Color statusColor(String status) {
    switch (status) {
      case 'open':
        return dangerColor;
      case 'on_progress':
        return warningColor;
      case 'resolved':
        return successColor;
      case 'closed':
        return Colors.grey;
      default:
        return primaryColor;
    }
  }

  static String statusLabel(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'on_progress':
        return 'On Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  static Color prioritasColor(String prioritas) {
    switch (prioritas) {
      case 'high':
        return dangerColor;
      case 'medium':
        return warningColor;
      case 'low':
        return successColor;
      default:
        return primaryColor;
    }
  }

  static String prioritasLabel(String prioritas) {
    switch (prioritas) {
      case 'high':
        return 'Tinggi';
      case 'medium':
        return 'Sedang';
      case 'low':
        return 'Rendah';
      default:
        return prioritas;
    }
  }

  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A2E),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0F1117),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1F2E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1C1F2E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF2A2D3E)),
        ),
      ),
    );
  }
}