import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final normalizedCurrentTheme = currentTheme.toLowerCase();

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
      title: Text(
        'App Theme',
        style: AppTextStyles.headlineSm.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context: context,
            value: 'system',
            title: 'System Default',
            subtitle: 'Matches device system theme',
            icon: Icons.brightness_auto_rounded,
            isSelected: normalizedCurrentTheme == 'system',
          ),
          const SizedBox(height: 6),
          _buildThemeOption(
            context: context,
            value: 'light',
            title: 'Light Mode',
            subtitle: 'Clean clinical white layout',
            icon: Icons.light_mode_rounded,
            isSelected: normalizedCurrentTheme == 'light',
          ),
          const SizedBox(height: 6),
          _buildThemeOption(
            context: context,
            value: 'dark',
            title: 'Dark Mode',
            subtitle: 'High-contrast dark layout',
            icon: Icons.dark_mode_rounded,
            isSelected: normalizedCurrentTheme == 'dark',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        onSelected(value);
        Navigator.of(context).pop();
      },
      borderRadius: AppRadius.radiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSm.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
