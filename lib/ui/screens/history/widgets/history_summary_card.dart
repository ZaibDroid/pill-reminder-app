import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../custom_widgets/progress_ring.dart';

class HistorySummaryCard extends StatelessWidget {
  final double adherenceRate;
  final String motivationalMessage;

  const HistorySummaryCard({
    super.key,
    required this.adherenceRate,
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
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ProgressRing(
            percentage: adherenceRate,
            size: 64,
            strokeWidth: 6,
            progressColor: theme.colorScheme.secondary,
            trackColor: theme.colorScheme.surfaceContainerHigh,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY ADHERENCE',
                  style: AppTextStyles.labelSm.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  motivationalMessage.isNotEmpty ? motivationalMessage : 'Keep up the good progress!',
                  style: AppTextStyles.headlineSm.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
