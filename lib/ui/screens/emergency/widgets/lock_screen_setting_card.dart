import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';

class LockScreenSettingCard extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const LockScreenSettingCard({
    super.key,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.screen_lock_portrait,
              color: AppColors.onPrimaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Show on Lock Screen',
                  style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Allow quick dial without unlocking.',
                  style: AppTextStyles.labelSm,
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryContainer.withValues(alpha: 0.5),
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
