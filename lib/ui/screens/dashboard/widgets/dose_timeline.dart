import 'package:flutter/material.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/time_slot.dart';
import '../../../../core/models/timeline_dose_item.dart';
import 'dose_timeline_card.dart';

class DoseTimeline extends StatelessWidget {
  final Map<TimeSlot, List<TimelineDoseItem>> groupedDoses;
  final Function(TimelineDoseItem) onTakeDose;
  final Function(TimelineDoseItem) onSkipDose;
  final Function(TimelineDoseItem)? onCardTap;

  const DoseTimeline({
    super.key,
    required this.groupedDoses,
    required this.onTakeDose,
    required this.onSkipDose,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final slots = [
      TimeSlot.morning,
      TimeSlot.afternoon,
      TimeSlot.evening,
      TimeSlot.night,
    ];

    final activeSlots = slots.where((s) => (groupedDoses[s]?.isNotEmpty ?? false)).toList();

    if (activeSlots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: activeSlots.map((slot) {
        final doses = groupedDoses[slot]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSlotHeader(context, slot),
            const SizedBox(height: 4),
            ...doses.map((dose) => DoseTimelineCard(
                  item: dose,
                  onTakeDose: () => onTakeDose(dose),
                  onSkipDose: () => onSkipDose(dose),
                  onCardTap: () => onCardTap?.call(dose),
                )),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSlotHeader(BuildContext context, TimeSlot slot) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    IconData icon;
    String label;

    switch (slot) {
      case TimeSlot.morning:
        icon = Icons.wb_sunny_rounded;
        label = 'Morning';
        break;
      case TimeSlot.afternoon:
        icon = Icons.wb_cloudy_rounded;
        label = 'Afternoon';
        break;
      case TimeSlot.evening:
        icon = Icons.bedtime_rounded;
        label = 'Evening';
        break;
      case TimeSlot.night:
        icon = Icons.nightlight_round;
        label = 'Night';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.headlineSm.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.3),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
