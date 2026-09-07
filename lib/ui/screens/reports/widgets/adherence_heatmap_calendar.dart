import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';

class AdherenceHeatmapCalendar extends StatelessWidget {
  final DateTime currentMonth;
  final Map<int, double>? dailyAdherenceRates;
  final Map<int, int>? dailyDoseCounts;

  const AdherenceHeatmapCalendar({
    super.key,
    required this.currentMonth,
    this.dailyAdherenceRates,
    this.dailyDoseCounts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(currentMonth.year, currentMonth.month, 1).weekday % 7; // 0 for Sun

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Adherence Heatmap',
            style: AppTextStyles.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Day header S M T W T F S
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('S', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
              Text('M', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
              Text('T', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
              Text('W', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
              Text('T', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
              Text('F', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
              Text('S', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday) {
                return const SizedBox.shrink();
              }
              final dayNumber = index - firstWeekday + 1;
              final dayDate = DateTime(currentMonth.year, currentMonth.month, dayNumber);
              final now = DateTime.now();
              final isFuture = dayDate.isAfter(DateTime(now.year, now.month, now.day, 23, 59, 59));
              final totalDoses = dailyDoseCounts?[dayNumber] ?? 0;
              final adherence = dailyAdherenceRates?[dayNumber] ?? 0.0;

              Color bg;
              Color fg;

              if (isFuture) {
                bg = theme.colorScheme.surfaceContainerLow;
                fg = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45);
              } else if (totalDoses == 0) {
                bg = theme.colorScheme.surfaceContainerHigh;
                fg = theme.colorScheme.onSurfaceVariant;
              } else if (adherence >= 100.0) {
                bg = theme.colorScheme.secondaryContainer;
                fg = theme.colorScheme.onSecondaryContainer;
              } else if (adherence >= 50.0) {
                bg = theme.colorScheme.tertiaryContainer;
                fg = theme.colorScheme.onTertiaryContainer;
              } else {
                bg = theme.colorScheme.errorContainer;
                fg = theme.colorScheme.onErrorContainer;
              }

              return Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
