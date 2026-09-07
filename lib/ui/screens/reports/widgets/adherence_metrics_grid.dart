import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';

class AdherenceMetricsGrid extends StatelessWidget {
  final double adherenceRate;
  final int longestStreak;
  final int takenDoses;
  final int totalDoses;

  const AdherenceMetricsGrid({
    super.key,
    required this.adherenceRate,
    required this.longestStreak,
    required this.takenDoses,
    required this.totalDoses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Metric 1: Overall Adherence
          _buildMetricCard(
            context: context,
            icon: Icons.insights,
            iconColor: theme.colorScheme.primary,
            title: 'Overall Adherence',
            value: '${adherenceRate.round()}%',
            extraWidget: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: adherenceRate / 100,
                backgroundColor: theme.colorScheme.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Metric 2: Longest Streak
              Expanded(
                child: _buildMetricCard(
                  context: context,
                  icon: Icons.local_fire_department,
                  iconColor: theme.colorScheme.secondary,
                  title: 'Longest Streak',
                  value: '$longestStreak Days',
                  subtext: 'Consecutive full adherence',
                ),
              ),
              const SizedBox(width: 10),
              // Metric 3: Total Doses Taken
              Expanded(
                child: _buildMetricCard(
                  context: context,
                  icon: Icons.medication,
                  iconColor: theme.colorScheme.tertiary,
                  title: 'Total Doses Taken',
                  value: '$takenDoses',
                  subtext: 'Out of $totalDoses scheduled',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? subtext,
    Widget? extraWidget,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMd.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.displayLg.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (extraWidget != null) ...[
            const SizedBox(height: 10),
            extraWidget,
          ],
          if (subtext != null) ...[
            const SizedBox(height: 4),
            Text(
              subtext,
              style: AppTextStyles.labelSm.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
