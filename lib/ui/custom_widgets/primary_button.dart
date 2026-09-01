import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_text_styles.dart';
import 'loading_indicator.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double height;
  final bool isFullWidth;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.height = 56.0,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFgColor = textColor ?? AppColors.onPrimary;

    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (isLoading)
          AppLoadingIndicator(
            size: 24.0,
            color: effectiveFgColor,
          )
        else ...[
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: effectiveFgColor,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: AppTextStyles.labelMd.copyWith(
              color: effectiveFgColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );

    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: effectiveFgColor,
        disabledBackgroundColor: (backgroundColor ?? AppColors.primary).withValues(alpha: 0.8),
        disabledForegroundColor: effectiveFgColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      onPressed: isLoading ? null : onPressed,
      child: buttonChild,
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    }

    return SizedBox(
      height: height,
      child: button,
    );
  }
}
