import 'package:flutter/material.dart';
import '../../../../app/locator.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/audio_alarm_service.dart';

class AlarmSoundSelectionDialog extends StatefulWidget {
  final String currentSound;
  final ValueChanged<String> onSelected;
  final bool isNotificationMode;
  final String? title;

  const AlarmSoundSelectionDialog({
    super.key,
    required this.currentSound,
    required this.onSelected,
    this.isNotificationMode = false,
    this.title,
  });

  @override
  State<AlarmSoundSelectionDialog> createState() => _AlarmSoundSelectionDialogState();
}

class _AlarmSoundSelectionDialogState extends State<AlarmSoundSelectionDialog> {
  late String _selectedSound;
  final AudioAlarmService _audioService = locator.isRegistered<AudioAlarmService>()
      ? locator<AudioAlarmService>()
      : AudioAlarmService();

  List<SoundItem> get _soundList => widget.isNotificationMode
      ? AudioAlarmService.notificationSounds
      : AudioAlarmService.medicineAlarmSounds;

  @override
  void initState() {
    super.initState();
    final defaultSound = widget.isNotificationMode ? 'Clinical Chime' : 'Morning Clock Alarm';
    _selectedSound = widget.currentSound.trim().isEmpty ? defaultSound : widget.currentSound;
  }

  @override
  void dispose() {
    _audioService.stopPreview();
    super.dispose();
  }

  void _onSelectOption(String title) {
    setState(() {
      _selectedSound = title;
    });
    // Immediately preview sound
    _audioService.playPreview(title);
  }

  void _onConfirm() {
    _audioService.stopPreview();
    widget.onSelected(_selectedSound);
    Navigator.of(context).pop();
  }

  void _onCancel() {
    _audioService.stopPreview();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedSelected = _selectedSound.trim().toLowerCase();

    final dialogTitle = widget.title ??
        (widget.isNotificationMode ? 'Select Notification Sound' : 'Select Alarm Sound');
    final dialogDesc = widget.isNotificationMode
        ? 'Tap a notification tone to listen to the preview, then tap Set to save for app notifications.'
        : 'Tap an alarm sound to hear the preview. This sound will ring when your medication is due.';

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.isNotificationMode ? Icons.notifications_active_rounded : Icons.volume_up_rounded,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              dialogTitle,
              style: AppTextStyles.headlineSm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dialogDesc,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ..._soundList.map((sound) {
                final isSelected = normalizedSelected == sound.title.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildSoundTile(
                    context: context,
                    sound: sound,
                    isSelected: isSelected,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
                onPressed: _onCancel,
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
                onPressed: _onConfirm,
                child: const Text(
                  'Set',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSoundTile({
    required BuildContext context,
    required SoundItem sound,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _onSelectOption(sound.title),
      borderRadius: AppRadius.radiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                sound.icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sound.title,
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    sound.subtitle,
                    style: AppTextStyles.labelSm.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                  width: 2,
                ),
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.circle, size: 10, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

