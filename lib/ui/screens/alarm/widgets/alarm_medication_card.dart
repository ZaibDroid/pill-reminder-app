import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/enums/meal_type.dart';
import '../../../../core/models/medicine.dart';
import '../../../custom_widgets/medicine_avatar.dart';

class AlarmMedicationCard extends StatelessWidget {
  final Medicine? medicine;
  final DateTime? scheduledTime;

  const AlarmMedicationCard({
    super.key,
    required this.medicine,
    this.scheduledTime,
  });

  String _getSlotTitle(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) {
      return 'SCHEDULED MORNING DOSE';
    } else if (hour >= 12 && hour < 17) {
      return 'SCHEDULED AFTERNOON DOSE';
    } else if (hour >= 17 && hour < 21) {
      return 'SCHEDULED EVENING DOSE';
    } else {
      return 'SCHEDULED NIGHT DOSE';
    }
  }

  String _getMealText(MealType? mealType) {
    switch (mealType) {
      case MealType.beforeMeal:
        return 'Take before food';
      case MealType.afterMeal:
        return 'Take after food';
      case MealType.withMeal:
        return 'Take with food';
      case MealType.noRelation:
      default:
        return 'Take with water';
    }
  }

  String _getGuidanceHeader(Medicine? medicine) {
    final text = medicine?.intakeGuidance.toLowerCase() ?? '';
    final form = medicine?.formFactor.toLowerCase() ?? '';
    if (text.contains('cotton') || text.contains('apply') || text.contains('fingertip') || form == 'gel' || form == 'cream' || form == 'ointment') {
      return 'APPLICATION';
    }
    return 'HYDRATION';
  }

  IconData _getGuidanceIcon(Medicine? medicine) {
    final text = medicine?.intakeGuidance.toLowerCase() ?? '';
    final form = medicine?.formFactor.toLowerCase() ?? '';
    if (text.contains('cotton') || text.contains('apply') || form == 'gel' || form == 'cream') {
      return Icons.clean_hands_rounded;
    } else if (text.contains('milk')) {
      return Icons.local_drink_rounded;
    } else if (text.contains('juice')) {
      return Icons.emoji_food_beverage_outlined;
    }
    return Icons.water_drop_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = scheduledTime ?? DateTime.now();
    final timeFormatted = DateFormat('hh:mm').format(now);
    final periodFormatted = DateFormat('a').format(now);
    final slotTitle = _getSlotTitle(now);

    final hasPhoto = medicine?.pillImageLocalPath != null &&
        medicine!.pillImageLocalPath!.isNotEmpty &&
        File(medicine!.pillImageLocalPath!).existsSync();

    const highlightTeal = Color(0xFF00D09C);
    final cardBg = isDark ? const Color(0xFF062521) : Colors.white;
    final cardBorder = isDark
        ? const Color(0xFF0D3D36)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.6);

    final dosageText = medicine != null
        ? '${medicine!.dosageValue.toStringAsFixed(medicine!.dosageValue.truncateToDouble() == medicine!.dosageValue ? 0 : 1)} ${medicine!.dosageUnit}'
        : '10 mg';

    final formText = medicine?.formFactor != null
        ? '${medicine!.formFactor[0].toUpperCase()}${medicine!.formFactor.substring(1)}'
        : 'Tablet';

    final periodWord = now.hour < 12 ? 'AM' : 'PM';
    final doctorNoteText = medicine?.prescriptionNotes != null &&
            medicine!.prescriptionNotes!.trim().isNotEmpty
        ? medicine!.prescriptionNotes!
        : '1 tablet once daily in $periodWord';

    return Column(
      children: [
        // 1. Time & Slot Title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              timeFormatted,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              periodFormatted,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: highlightTeal,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          slotTitle,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: highlightTeal,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 18),

        // 2. Verified Medicine Photo Hero Card with luminous ambient glow
        Container(
          width: double.infinity,
          height: 195,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF082B26) : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? highlightTeal.withValues(alpha: 0.35)
                  : theme.colorScheme.primary.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              // Ambient cyan glow
              BoxShadow(
                color: isDark
                    ? highlightTeal.withValues(alpha: 0.22)
                    : highlightTeal.withValues(alpha: 0.10),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Actual Photo or High-Res Pill Avatar
                if (hasPhoto)
                  Image.file(
                    File(medicine!.pillImageLocalPath!),
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF0C3831), const Color(0xFF041916)]
                            : [const Color(0xFFE2FAF3), const Color(0xFFCCEFE6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: MedicineAvatar(
                        imagePath: medicine?.pillImageLocalPath,
                        formFactor: medicine?.formFactor ?? 'tablet',
                        size: 96,
                        isCircle: false,
                        borderRadius: BorderRadius.circular(22),
                        backgroundColor: isDark
                            ? const Color(0xFF0E453D)
                            : theme.colorScheme.primaryContainer,
                        iconColor: highlightTeal,
                        iconSize: 48,
                      ),
                    ),
                  ),

                // Bottom Gradient Scrim with Badges
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Verified Photo badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: highlightTeal.withValues(alpha: 0.45),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: highlightTeal,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                hasPhoto ? 'Verified Photo' : 'Verified Dosage',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Dosage Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            dosageText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 3. Clinical Details Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cardBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Prescription Dose Badge & Rx Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF093630) : const Color(0xFFE0F7F2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark_added_rounded, size: 14, color: highlightTeal),
                        const SizedBox(width: 6),
                        const Text(
                          'Prescription Dose',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: highlightTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF093630) : theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      size: 17,
                      color: highlightTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Medicine Name
              Text(
                medicine?.name ?? 'Sertraline HCl',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),

              // Subtitle: "50 mg Oral Tablet"
              Text(
                '$dosageText Oral $formText',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF90B8B2) : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),

              // 2-Column Info Grid: Instruction & Hydration
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF031916) : const Color(0xFFF2FBF8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF0B3A33)
                              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.restaurant_rounded, size: 14, color: highlightTeal),
                              const SizedBox(width: 5),
                              Text(
                                'INSTRUCTION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.grey[400] : theme.colorScheme.onSurfaceVariant,
                                  letterSpacing: 0.9,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _getMealText(medicine?.mealType),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF031916) : const Color(0xFFF2FBF8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF0B3A33)
                              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(_getGuidanceIcon(medicine), size: 14, color: highlightTeal),
                              const SizedBox(width: 5),
                              Text(
                                _getGuidanceHeader(medicine),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.grey[400] : theme.colorScheme.onSurfaceVariant,
                                  letterSpacing: 0.9,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            medicine?.intakeGuidance != null && medicine!.intakeGuidance.trim().isNotEmpty
                                ? medicine!.intakeGuidance
                                : 'Full glass water',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Doctor Note Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF031916) : const Color(0xFFF2FBF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF0B3A33)
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.health_and_safety_outlined, size: 15, color: highlightTeal),
                    const SizedBox(width: 6),
                    const Text(
                      'Doctor note: ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: highlightTeal,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        doctorNoteText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

