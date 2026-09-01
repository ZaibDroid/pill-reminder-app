import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/enums/medicine_status.dart';

enum BadgeVariant {
  taken,
  skipped,
  missed,
  pending,
  urgent,
  prescription,
  custom,
}

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const StatusBadge({
    super.key,
    required this.text,
    this.variant = BadgeVariant.custom,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  factory StatusBadge.fromMedicineStatus(MedicineStatus status) {
    switch (status) {
      case MedicineStatus.taken:
        return const StatusBadge(
          text: 'Taken',
          variant: BadgeVariant.taken,
          icon: Icons.check_circle,
        );
      case MedicineStatus.skipped:
        return const StatusBadge(
          text: 'Skipped',
          variant: BadgeVariant.skipped,
          icon: Icons.do_not_disturb_on,
        );
      case MedicineStatus.missed:
        return const StatusBadge(
          text: 'Missed',
          variant: BadgeVariant.missed,
          icon: Icons.cancel,
        );
      case MedicineStatus.pending:
        return const StatusBadge(
          text: 'Upcoming',
          variant: BadgeVariant.pending,
          icon: Icons.schedule,
        );
    }
  }

  factory StatusBadge.urgent() {
    return const StatusBadge(
      text: 'Urgent',
      variant: BadgeVariant.urgent,
      icon: Icons.priority_high,
    );
  }

  factory StatusBadge.prescription({String label = 'Prescription'}) {
    return StatusBadge(
      text: label,
      variant: BadgeVariant.prescription,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData? badgeIcon = icon;

    switch (variant) {
      case BadgeVariant.taken:
        bg = AppColors.secondaryContainer.withValues(alpha: 0.35);
        fg = AppColors.onSecondaryContainer;
        badgeIcon ??= Icons.check_circle;
        break;
      case BadgeVariant.skipped:
        bg = AppColors.surfaceContainer;
        fg = AppColors.outline;
        badgeIcon ??= Icons.do_not_disturb_on;
        break;
      case BadgeVariant.missed:
        bg = AppColors.errorContainer;
        fg = AppColors.error;
        badgeIcon ??= Icons.cancel;
        break;
      case BadgeVariant.pending:
        bg = AppColors.surfaceVariant;
        fg = AppColors.onSurfaceVariant;
        badgeIcon ??= Icons.schedule;
        break;
      case BadgeVariant.urgent:
        bg = AppColors.error;
        fg = AppColors.onError;
        badgeIcon ??= Icons.priority_high;
        break;
      case BadgeVariant.prescription:
        bg = AppColors.surfaceVariant;
        fg = AppColors.onSurfaceVariant;
        break;
      case BadgeVariant.custom:
        bg = backgroundColor ?? AppColors.primaryContainer.withValues(alpha: 0.15);
        fg = textColor ?? AppColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeIcon != null) ...[
            Icon(
              badgeIcon,
              size: 14,
              color: fg,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTextStyles.labelSm.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
