import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

/// Typography scale extracted from Stitch "MediAlert Clinical Humanist" design tokens (Inter font family).
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  // display-lg: 32px, Bold (700), LineHeight: 40px, LetterSpacing: -0.02em
  static TextStyle get displayLg => TextStyle(
        fontFamily: fontFamily,
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
        color: AppColors.primary,
      );

  // headline-lg-mobile: 28px, Bold (700), LineHeight: 36px
  static TextStyle get headlineLgMobile => TextStyle(
        fontFamily: fontFamily,
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
        color: AppColors.onSurface,
      );

  // headline-md: 24px, SemiBold (600), LineHeight: 32px, LetterSpacing: -0.01em
  static TextStyle get headlineMd => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.01 * 24,
        color: AppColors.onSurface,
      );

  // headline-sm: 20px, SemiBold (600), LineHeight: 28px
  static TextStyle get headlineSm => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: AppColors.onSurface,
      );

  // body-lg: 18px, Regular (400), LineHeight: 28px
  static TextStyle get bodyLg => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18.sp,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: AppColors.onSurface,
      );

  // body-md: 16px, Regular (400), LineHeight: 24px
  static TextStyle get bodyMd => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurfaceVariant,
      );

  // label-md: 14px, SemiBold (600), LineHeight: 20px, LetterSpacing: 0.01em
  static TextStyle get labelMd => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.01 * 14,
        color: AppColors.onSurface,
      );

  // label-sm: 12px, Medium (500), LineHeight: 16px
  static TextStyle get labelSm => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: AppColors.onSurfaceVariant,
      );

  // Legacy aliases to prevent breakages
  static TextStyle get heading1 => displayLg;
  static TextStyle get heading2 => headlineMd;
  static TextStyle get heading3 => headlineSm;
  static TextStyle get bodyLarge => bodyLg;
  static TextStyle get bodyMedium => bodyMd;
  static TextStyle get bodySmall => labelSm;
  static TextStyle get buttonText => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
}
