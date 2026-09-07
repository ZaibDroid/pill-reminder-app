import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../custom_widgets/progress_ring.dart';

class AdherenceCard extends StatelessWidget {
  final double adherenceRate;
  final int takenDoses;
  final int totalDoses;
  final String motivationalMessage;

  const AdherenceCard({
    super.key,
    required this.adherenceRate,
    required this.takenDoses,
    required this.totalDoses,
    required this.motivationalMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Adherence",
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: AppTextStyles.bodyMd.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    children: [
                      const TextSpan(text: "You've taken "),
                      TextSpan(
                        text: '$takenDoses of $totalDoses',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: ' doses today'),
                    ],
                  ),
                ),
                if (motivationalMessage.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    motivationalMessage,
                    style: AppTextStyles.labelSm.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          ProgressRing(
            percentage: adherenceRate,
            size: 72,
            strokeWidth: 8,
            progressColor: theme.colorScheme.primary,
            trackColor: theme.colorScheme.surfaceContainerHigh,
          ),
        ],
      ),
    );
  }
}
