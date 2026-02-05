// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primary = Color(0xFF2D6CFF);
  static const primaryDark = Color(0xFF1A4FD6);
  static const primaryLight = Color(0xFF5B8DFF);

  // Accent Colors
  static const accent = Color(0xFFFF6B6B);
  static const accentLight = Color(0xFFFF9494);

  // Success & Income
  static const success = Color(0xFF4CAF50);
  static const successLight = Color(0xFF81C784);
  static const income = Color(0xFF00D09C);
  static const incomeBackground = Color(0xFFE8F5E9);

  // Error & Expense
  static const error = Color(0xFFEF5350);
  static const errorLight = Color(0xFFE57373);
  static const expense = Color(0xFFFF6B6B);
  static const expenseBackground = Color(0xFFFFEBEE);

  // Neutral Colors
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const textPrimary = Color(0xFF1A1D1F);
  static const textSecondary = Color(0xFF6F767E);
  static const textTertiary = Color(0xFF9A9FA5);
  static const textDisabled = Color(0xFFCCCCCC);

  // Border & Divider
  static const border = Color(0xFFEFEFEF);
  static const divider = Color(0xFFE5E5E5);

  // Shadows
  static const shadow = Color(0x1A000000);
  static const shadowLight = Color(0x0D000000);

  // Dark Theme Colors
  static const backgroundDark = Color(0xFF121212);
  static const surfaceDark = Color(0xFF1E1E1E);
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFFB3B3B3);

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFFEF4444), // Red
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
    Color(0xFF06B6D4), // Cyan
  ];

  // Gradient Backgrounds
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF2D6CFF), Color(0xFF5B8DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const incomeGradient = LinearGradient(
    colors: [Color(0xFF00D09C), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const expenseGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFEF5350)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
