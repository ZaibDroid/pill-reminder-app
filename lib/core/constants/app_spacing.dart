import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing and padding tokens matching Stitch MediAlert design system.
class AppSpacing {
  AppSpacing._();

  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 48.w;
  static double get marginMobile => 16.w;
  static double get marginDesktop => 64.w;

  static SizedBox get verticalXs => SizedBox(height: xs);
  static SizedBox get verticalSm => SizedBox(height: sm);
  static SizedBox get verticalMd => SizedBox(height: md);
  static SizedBox get verticalLg => SizedBox(height: lg);
  static SizedBox get verticalXl => SizedBox(height: xl);
  static SizedBox get verticalXxl => SizedBox(height: xxl);

  static SizedBox get horizontalXs => SizedBox(width: xs);
  static SizedBox get horizontalSm => SizedBox(width: sm);
  static SizedBox get horizontalMd => SizedBox(width: md);
  static SizedBox get horizontalLg => SizedBox(width: lg);
  static SizedBox get horizontalXl => SizedBox(width: xl);
  static SizedBox get horizontalXxl => SizedBox(width: xxl);

  static EdgeInsets get screenPadding => EdgeInsets.symmetric(
        horizontal: marginMobile,
        vertical: md,
      );

  static EdgeInsets get cardPadding => EdgeInsets.all(md);
}
