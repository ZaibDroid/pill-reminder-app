import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';

class ThemeSelectionDialog extends StatelessWidget {
  final String currentTheme;
  final ValueChanged<String> onSelected;

  const ThemeSelectionDialog({
    super.key,
    required this.currentTheme,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
      title: Text(
        'App Theme',
        style: AppTextStyles.headlineSm.copyWith(fontWeight: FontWeight.w700),
      ),
      content: RadioGroup<String>(
        groupValue: currentTheme,
        onChanged: (val) {
          if (val != null) {
            onSelected(val);
            Navigator.of(context).pop();
          }
        },
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: 'system',
              title: Text('System Default'),
              activeColor: AppColors.primary,
            ),
            RadioListTile<String>(
              value: 'light',
              title: Text('Light'),
              activeColor: AppColors.primary,
            ),
            RadioListTile<String>(
              value: 'dark',
              title: Text('Dark'),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
