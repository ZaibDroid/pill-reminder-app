import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surfaceContainerLowest,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXl,
          side: const BorderSide(color: AppColors.surfaceContainerHigh, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceVariant,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXl,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AppColors.onSurface),
        headlineMedium: TextStyle(color: AppColors.onSurface),
        headlineSmall: TextStyle(color: AppColors.onSurface),
        bodyLarge: TextStyle(color: AppColors.onSurface),
        bodyMedium: TextStyle(color: AppColors.onSurfaceVariant),
        bodySmall: TextStyle(color: AppColors.onSurfaceVariant),
        labelLarge: TextStyle(color: AppColors.onSurface),
        labelMedium: TextStyle(color: AppColors.onSurface),
        labelSmall: TextStyle(color: AppColors.onSurfaceVariant),
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF121619);
    const darkSurface = Color(0xFF1E2529);
    const darkSurfaceLow = Color(0xFF161C20);
    const darkSurfaceContainer = Color(0xFF222B31);
    const darkSurfaceHigh = Color(0xFF2C373E);
    const darkSurfaceHighest = Color(0xFF37444D);
    const darkOnSurface = Color(0xFFF0F4F6);
    const darkOnSurfaceVariant = Color(0xFFA5B6BD);
    const darkBorder = Color(0xFF333E46);
    const darkPrimary = Color(0xFF00BFA5);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF004D40),
        onPrimaryContainer: Color(0xFF80CBC4),
        secondary: AppColors.secondaryFixedDim,
        onSecondary: AppColors.onSecondaryFixed,
        secondaryContainer: Color(0xFF1B382B),
        onSecondaryContainer: Color(0xFF6BFF8F),
        tertiary: AppColors.tertiaryFixedDim,
        onTertiary: AppColors.onTertiaryFixed,
        tertiaryContainer: Color(0xFF4A2818),
        onTertiaryContainer: Color(0xFFFFCCAA),
        error: Color(0xFFFF6B6B),
        onError: Colors.white,
        errorContainer: Color(0xFF4A181C),
        onErrorContainer: Color(0xFFFFB4AB),
        surface: darkSurface,
        surfaceContainerLowest: darkBackground,
        surfaceContainerLow: darkSurfaceLow,
        surfaceContainer: darkSurfaceContainer,
        surfaceContainerHigh: darkSurfaceHigh,
        surfaceContainerHighest: darkSurfaceHighest,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkOnSurfaceVariant,
        outline: darkBorder,
        outlineVariant: Color(0xFF2E3940),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkPrimary),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXl,
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXl,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: darkOnSurface),
        headlineMedium: TextStyle(color: darkOnSurface),
        headlineSmall: TextStyle(color: darkOnSurface),
        bodyLarge: TextStyle(color: darkOnSurface),
        bodyMedium: TextStyle(color: darkOnSurfaceVariant),
        bodySmall: TextStyle(color: darkOnSurfaceVariant),
        labelLarge: TextStyle(color: darkOnSurface),
        labelMedium: TextStyle(color: darkOnSurface),
        labelSmall: TextStyle(color: darkOnSurfaceVariant),
      ),
    );
  }
}
