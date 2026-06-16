import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Two [ThemeData] personas. The senior theme is the app default
/// (the role-split first screen is the senior-app entry point).
class AppTheme {
  AppTheme._();

  static ThemeData get senior {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.seniorPrimary,
          brightness: Brightness.light,
        ).copyWith(
          surface: AppColors.seniorSurface,
          onSurface: AppColors.seniorOnSurface,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.seniorBackground,
      // Larger defaults for senior-facing UI.
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 22),
        labelLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData get guardian {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.guardianPrimary,
          brightness: Brightness.light,
        ).copyWith(
          surface: AppColors.guardianSurface,
          onSurface: AppColors.guardianOnSurface,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.guardianBackground,
    );
  }
}
