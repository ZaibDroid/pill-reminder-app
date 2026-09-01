import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
            _buildSlotHeader(slot),
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

  Widget _buildSlotHeader(TimeSlot slot) {
    IconData icon;
    String label;

    switch (slot) {
      case TimeSlot.morning:
        icon = Icons.wb_sunny;
        label = 'Morning';
        break;
      case TimeSlot.afternoon:
        icon = Icons.wb_cloudy;
        label = 'Afternoon';
        break;
      case TimeSlot.evening:
        icon = Icons.bedtime;
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
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.headlineSm.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Divider(
              color: AppColors.surfaceVariant,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
