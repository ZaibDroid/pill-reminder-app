import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../custom_widgets/custom_text_field.dart';
import '../../../viewmodels/add_medicine_viewmodel.dart';

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

  @override
  void initState() {
    super.initState();
    _doctorController = TextEditingController(text: widget.viewModel.doctorName ?? '');
    _notesController = TextEditingController(text: widget.viewModel.prescriptionNotes ?? '');
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
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Duration Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Duration', style: AppTextStyles.headlineSm.copyWith(fontSize: 18, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ongoing Medication', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('No predetermined end date'),
                value: viewModel.isOngoing,
                activeThumbColor: AppColors.primary,
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
                        Text('Start Date', style: AppTextStyles.labelSm),
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
                              color: AppColors.surfaceContainerLow,
                              borderRadius: AppRadius.radiusMd,
                              border: Border.all(color: AppColors.outlineVariant),
                            ),
                            child: Text(DateFormat('yyyy-MM-dd').format(viewModel.startDate)),
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
                          Text('End Date', style: AppTextStyles.labelSm),
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
                                color: AppColors.surfaceContainerLow,
                                borderRadius: AppRadius.radiusMd,
                                border: Border.all(color: AppColors.outlineVariant),
                              ),
                              child: Text(
                                viewModel.endDate != null
                                    ? DateFormat('yyyy-MM-dd').format(viewModel.endDate!)
                                    : 'Select date',
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
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Reminder Settings', style: AppTextStyles.headlineSm.copyWith(fontSize: 18, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('High Priority Alarm', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Bypasses silent mode for critical doses'),
                value: viewModel.isHighPriority,
                activeThumbColor: AppColors.tertiary,
                onChanged: (val) => viewModel.isHighPriority = val,
              ),
              const SizedBox(height: 8),
              Text('Alarm Sound', style: AppTextStyles.labelSm),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: viewModel.alarmSound,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'Classic Alarm', child: Text('Classic Alarm')),
                      DropdownMenuItem(value: 'Chime (Default)', child: Text('Chime (Default)')),
                      DropdownMenuItem(value: 'Gentle Beep', child: Text('Gentle Beep')),
                      DropdownMenuItem(value: 'Vibrate Only', child: Text('Vibrate Only')),
                    ],
                    onChanged: (val) {
                      if (val != null) viewModel.alarmSound = val;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Optional Doctor & Notes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.note_add, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Optional Details', style: AppTextStyles.headlineSm.copyWith(fontSize: 18, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Prescribing Doctor',
                hintText: 'e.g., Dr. Sarah Mitchell',
                prefixIcon: const Icon(Icons.person_outline),
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
