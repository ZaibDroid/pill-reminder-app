import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(currentMonth.year, currentMonth.month, 1).weekday % 7; // 0 for Sun

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Adherence Heatmap',
            style: AppTextStyles.headlineSm.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          // Day header S M T W T F S
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('S', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
              Text('M', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
              Text('T', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
              Text('W', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
              Text('T', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
              Text('F', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
              Text('S', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
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
              final totalDoses = dailyDoseCounts?[dayNumber] ?? 0;
              final adherence = dailyAdherenceRates?[dayNumber] ?? 0.0;

              Color bg;
              Color fg;

              if (totalDoses == 0) {
                bg = AppColors.surfaceVariant;
                fg = AppColors.onSurfaceVariant;
              } else if (adherence >= 100.0) {
                bg = AppColors.secondaryContainer;
                fg = AppColors.onSecondaryContainer;
              } else if (adherence >= 50.0) {
                bg = AppColors.tertiaryContainer;
                fg = AppColors.onTertiaryContainer;
              } else {
                bg = AppColors.errorContainer;
                fg = AppColors.error;
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
