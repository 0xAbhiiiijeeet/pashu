import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF666B42); // Dark olive green
  static const Color cream = Color(0xFFFAE4B2); // Warm cream
  static const Color golden = Color(0xFFA49561); // Golden brown
  static const Color sage = Color(0xFF828866); // Muted sage
  static const Color offWhite = Color(0xFFF5F5F5); // Off-white
  static const Color mintGreen = Color(0xFFD7E4DA); // Pale mint

  // Semantic
  static const Color background = offWhite;
  static const Color surface = Colors.white;
  static const Color surfaceVariant = mintGreen;
  static const Color cardBg = Colors.white;
  static const Color divider = Color(0xFFE0E0E0);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, sage],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient creamGradient = LinearGradient(
    colors: [cream, offWhite],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
