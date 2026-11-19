import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF5636F5);
  static const Color primarySecondary = Color(0xFF7657FF);
  static const Color lightPurple = Color(0xFFEAE4FF);
  static const Color lavenderBackground = Color(0xFFF8F6FF);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkNavy = Color(0xFF111044);
  static const Color secondaryText = Color(0xFF625B94);
  static const Color borderColor = Color(0xFFE5DEFF);

  // Status Colors
  static const Color successGreen = Color(0xFF22C55E);
  static const Color errorRed = Color(0xFFFF3B45);
  static const Color warningOrange = Color(0xFFFF9500);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF11111D);
  static const Color darkSurface = Color(0xFF1B1A2A);
  static const Color darkCard = Color(0xFF252436);
  static const Color darkBorder = Color(0xFF2D2B45);
  static const Color darkSecondaryText = Color(0xFF8B84C0);

  // Category Colors
  static const Color workColor = Color(0xFF5636F5);
  static const Color personalColor = Color(0xFFFF6B35);
  static const Color healthColor = Color(0xFF22C55E);
  static const Color studyColor = Color(0xFFFFB800);
  static const Color darkBlue = Color(0x445636F5);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primarySecondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFF8F6FF), Color(0xFFEAE4FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkBackground, darkSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
