import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Metric 1: Overall Adherence
          _buildMetricCard(
            icon: Icons.insights,
            iconColor: AppColors.primary,
            title: 'Overall Adherence',
            value: '${adherenceRate.round()}%',
            extraWidget: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: adherenceRate / 100,
                backgroundColor: AppColors.surfaceContainer,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                  icon: Icons.local_fire_department,
                  iconColor: AppColors.secondary,
                  title: 'Longest Streak',
                  value: '$longestStreak Days',
                  subtext: 'Consecutive full adherence',
                ),
              ),
              const SizedBox(width: 10),
              // Metric 3: Total Doses Taken
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.medication,
                  iconColor: AppColors.tertiary,
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
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? subtext,
    Widget? extraWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                    color: AppColors.onSurfaceVariant,
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
              color: AppColors.onSurface,
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
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
