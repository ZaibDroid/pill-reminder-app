import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../custom_widgets/custom_text_field.dart';
import '../../../viewmodels/add_medicine_viewmodel.dart';
import '../../settings/widgets/alarm_sound_selection_dialog.dart';

class StepRemindersDuration extends StatefulWidget {
  final AddMedicineViewModel viewModel;

  const StepRemindersDuration({
    super.key,
    required this.viewModel,
  });

  @override
  State<StepRemindersDuration> createState() => _StepRemindersDurationState();
}

class _StepRemindersDurationState extends State<StepRemindersDuration> {
  late final TextEditingController _doctorController;
  late final TextEditingController _notesController;
  late final TextEditingController _stockController;
  late final TextEditingController _thresholdController;

  @override
  void initState() {
    super.initState();
    _doctorController = TextEditingController(text: widget.viewModel.doctorName ?? '');
    _notesController = TextEditingController(text: widget.viewModel.prescriptionNotes ?? '');
    _stockController = TextEditingController(text: widget.viewModel.currentStock.toString());
    _thresholdController = TextEditingController(text: widget.viewModel.lowStockThreshold.toString());
  }

  @override
  void didUpdateWidget(covariant StepRemindersDuration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_doctorController.text != (widget.viewModel.doctorName ?? '')) {
      _doctorController.text = widget.viewModel.doctorName ?? '';
    }
    if (_notesController.text != (widget.viewModel.prescriptionNotes ?? '')) {
      _notesController.text = widget.viewModel.prescriptionNotes ?? '';
    }
    if (_stockController.text != widget.viewModel.currentStock.toString()) {
      _stockController.text = widget.viewModel.currentStock.toString();
    }
    if (_thresholdController.text != widget.viewModel.lowStockThreshold.toString()) {
      _thresholdController.text = widget.viewModel.lowStockThreshold.toString();
    }
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _notesController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Duration Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Duration',
                    style: AppTextStyles.headlineSm.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Ongoing Medication',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'No predetermined end date',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                value: viewModel.isOngoing,
                activeThumbColor: theme.colorScheme.primary,
                activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.35),
                onChanged: (val) {
                  viewModel.isOngoing = val;
                  if (val) viewModel.endDate = null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date',
                          style: AppTextStyles.labelSm.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: viewModel.startDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2040),
                            );
                            if (picked != null) viewModel.startDate = picked;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: AppRadius.radiusMd,
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
                              ),
                            ),
                            child: Text(
                              DateFormat('yyyy-MM-dd').format(viewModel.startDate),
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!viewModel.isOngoing) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Date',
                            style: AppTextStyles.labelSm.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: viewModel.endDate ?? viewModel.startDate.add(const Duration(days: 7)),
                                firstDate: viewModel.startDate,
                                lastDate: DateTime(2040),
                              );
                              if (picked != null) viewModel.endDate = picked;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerLow,
                                borderRadius: AppRadius.radiusMd,
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
                                ),
                              ),
                              child: Text(
                                viewModel.endDate != null
                                    ? DateFormat('yyyy-MM-dd').format(viewModel.endDate!)
                                    : 'Select date',
                                style: TextStyle(
                                  color: viewModel.endDate != null
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Reminder Priority & Sound
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_active, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Reminder Settings',
                    style: AppTextStyles.headlineSm.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'High Priority Alarm',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Bypasses silent mode for critical doses',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                value: viewModel.isHighPriority,
                activeThumbColor: theme.colorScheme.tertiary,
                activeTrackColor: theme.colorScheme.tertiary.withValues(alpha: 0.35),
                onChanged: (val) => viewModel.isHighPriority = val,
              ),
              const SizedBox(height: 8),
              Text(
                'Alarm Sound',
                style: AppTextStyles.labelSm.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlarmSoundSelectionDialog(
                      currentSound: viewModel.alarmSound,
                      onSelected: (val) {
                        viewModel.alarmSound = val;
                      },
                    ),
                  );
                },
                borderRadius: AppRadius.radiusMd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadius.radiusMd,
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.music_note_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          viewModel.alarmSound,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Stock & Inventory Tracking
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2_rounded, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Stock & Refill Tracking',
                    style: AppTextStyles.headlineSm.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Stock Count',
                          style: AppTextStyles.labelSm.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: AppRadius.radiusMd,
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 20),
                                onPressed: viewModel.currentStock > 0
                                    ? () {
                                        viewModel.currentStock--;
                                        _stockController.text = viewModel.currentStock.toString();
                                      }
                                    : null,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _stockController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.headlineSm.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  onChanged: (val) {
                                    final parsed = int.tryParse(val);
                                    if (parsed != null && parsed >= 0) {
                                      viewModel.currentStock = parsed;
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                onPressed: () {
                                  viewModel.currentStock++;
                                  _stockController.text = viewModel.currentStock.toString();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Low Stock Refill Alert',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Get notified when medicine supply runs low',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                value: viewModel.isRefillAlertEnabled,
                activeThumbColor: theme.colorScheme.primary,
                activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.35),
                onChanged: (val) => viewModel.isRefillAlertEnabled = val,
              ),
              if (viewModel.isRefillAlertEnabled) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Alert when remaining drops below:',
                        style: AppTextStyles.labelSm.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                    Container(
                      width: 90,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
                        ),
                      ),
                      child: TextField(
                        controller: _thresholdController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          suffixText: 'left',
                          suffixStyle: TextStyle(fontSize: 12),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        ),
                        onChanged: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null && parsed >= 1) {
                            viewModel.lowStockThreshold = parsed;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Optional Doctor & Notes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.note_add, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Optional Details',
                    style: AppTextStyles.headlineSm.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Prescribing Doctor',
                hintText: 'e.g., Dr. Sarah Mitchell',
                prefixIcon: Icon(Icons.person_outline, color: theme.colorScheme.onSurfaceVariant),
                controller: _doctorController,
                onChanged: (val) => viewModel.doctorName = val,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Instructions / Notes',
                hintText: 'Take with food, avoid grapefruit...',
                maxLines: 3,
                controller: _notesController,
                onChanged: (val) => viewModel.prescriptionNotes = val,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
