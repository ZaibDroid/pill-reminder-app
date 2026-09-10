import 'package:flutter/material.dart';
import '../../../../core/constants/app_radius.dart';

class AlarmActionButtons extends StatelessWidget {
  final VoidCallback onMarkTaken;
  final VoidCallback onSnooze;
  final VoidCallback onSkip;
  final VoidCallback? onCallCaregiver;
  final String takeButtonLabel;

  const AlarmActionButtons({
    super.key,
    required this.onMarkTaken,
    required this.onSnooze,
    required this.onSkip,
    this.onCallCaregiver,
    this.takeButtonLabel = 'Take Dose (1 Tablet)',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const emeraldAccent = Color(0xFF00D09C);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Primary: Take Dose Glowing Emerald Button
        Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: [
              BoxShadow(
                color: emeraldAccent.withValues(alpha: isDark ? 0.35 : 0.25),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: emeraldAccent,
              foregroundColor: const Color(0xFF04241E),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            onPressed: onMarkTaken,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 22,
                  color: Color(0xFF04241E),
                ),
                const SizedBox(width: 10),
                Text(
                  takeButtonLabel,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: Color(0xFF04241E),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. Secondary Action Row: Snooze & Skip
        Row(
          children: [
            // Snooze (10m) Button
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF0C302B)
                        : theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                    foregroundColor: isDark ? Colors.white : theme.colorScheme.primary,
                    elevation: 0,
                    side: BorderSide(
                      color: isDark ? const Color(0xFF144D44) : theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  onPressed: onSnooze,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: isDark ? emeraldAccent : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Snooze (10m)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Skip Dose Button
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF122220)
                        : theme.colorScheme.surfaceContainerHigh,
                    foregroundColor: isDark ? const Color(0xFF90ABA6) : theme.colorScheme.onSurfaceVariant,
                    elevation: 0,
                    side: BorderSide(
                      color: isDark ? const Color(0xFF1D3834) : theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  onPressed: onSkip,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark ? const Color(0xFF90ABA6) : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Skip Dose',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF90ABA6) : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // 3. Bottom Footer Link: Need Caregiver Assistance?
        if (onCallCaregiver != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onCallCaregiver,
            icon: Icon(
              Icons.phone_in_talk_outlined,
              size: 15,
              color: isDark ? const Color(0xFF7AA6A0) : theme.colorScheme.onSurfaceVariant,
            ),
            label: Text(
              'Need Caregiver Assistance?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF7AA6A0) : theme.colorScheme.onSurfaceVariant,
                decoration: TextDecoration.underline,
                decorationColor: isDark ? const Color(0xFF7AA6A0) : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
