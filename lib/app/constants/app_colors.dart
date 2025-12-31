import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF025786);
  static const Color primaryTeal = Color(0xFF00E7D8);
  static const Color primaryTealAlt = Color(0xFF00EDD6);
  static const Color lightBlue = Color(0xFF00BDE8);
  static const Color cyan = Color(0xFF00FFD0);
  static const Color brightTealGreen = Color(0xFF50E3C2);
  static const Color veryLightMintGreen = Color(0xFFE0FFF7);
  
  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  
  // Gray Shades
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color mediumGray = Color(0xFF666666);
  static const Color darkGray = Color(0xFF333333);
  static const Color veryLightGray = Color(0xFFF8F9FA);
  static const Color lightGrayAlt = Color(0xFFAAAAAA);
  static const Color gray400 = Color(0xFF6B6E80);
  static const Color gray200 = Color(0xFFF2F4FC);
  
  // Accent Colors
  static const Color red = Colors.red;
  static const Color red700 = Color(0xFFC62828);
  static const Color purple = Colors.purple;
  static const Color orange = Colors.orange;
  static const Color orange300 = Color(0xFFFFB74D);
  static const Color orange700 = Color(0xFFF57C00);
  static const Color blueAccent = Color(0xFF3F52B4);
  
  // Background Colors
  static const Color backgroundGray = Color(0xFFF8F9FA);
  static const Color backgroundLightGray = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color textBlack = Colors.black;
  static const Color textWhite = Colors.white;
  static const Color textGray = Color(0xFF666666);
  static const Color textDarkGray = Color(0xFF333333);
  static const Color textMediumGray = Color(0xFF525252);
  static const Color textLightGray = Color(0xFF373B51);
  
  // Border Colors
  static const Color borderLightGray = Color(0xFFE0E0E0);
  static const Color borderGray = Colors.grey;
  
  // Shadow Colors
  static Color shadowBlack = Colors.black.withValues(alpha: 0.05);
  static Color shadowBlackLight = Colors.black.withValues(alpha: 0.09);
  static Color shadowBlackMedium = Colors.black.withValues(alpha: 0.1);
  static Color shadowBlackHeavy = Colors.black.withValues(alpha: 0.15);
  static Color shadowBlackVeryHeavy = Colors.black.withValues(alpha: 0.3);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF00BDE8),
    Color(0xFF00FFD0),
  ];
  
  static List<Color> primaryGradientWithOpacity(double opacity) => [
    lightBlue.withValues(alpha: opacity),
    cyan.withValues(alpha: opacity),
  ];
  
  // Specific UI Colors
  static const Color favoriteRed = Colors.red;
  static const Color favoriteGray = Color(0xFF666666);
  static const Color selectedFilterBlue = Color(0xFF3F52B4);
  static const Color unselectedFilterGray = Color(0xFF6B6E80);
  static const Color filterBackground = Color(0xFFF2F4FC);
  
  // Settings Colors
  static const Color settingsCardBackground = Color(0xFFE0FFF7);
  static const Color settingsBorderTeal = Color(0xFF50E3C2);
  static const Color settingsExcludedFeatureGray = Color(0xFFAAAAAA);
  
  // Helper methods for opacity variations
  static Color whiteWithOpacity(double opacity) => Colors.white.withValues(alpha: opacity);
  static Color blackWithOpacity(double opacity) => Colors.black.withValues(alpha: opacity);
  static Color grayWithOpacity(double opacity) => Colors.grey.withValues(alpha: opacity);
}

