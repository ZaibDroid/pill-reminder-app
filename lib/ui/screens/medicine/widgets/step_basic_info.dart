import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../custom_widgets/custom_text_field.dart';
import '../../../viewmodels/add_medicine_viewmodel.dart';

class StepBasicInfo extends StatefulWidget {
  final AddMedicineViewModel viewModel;

  const StepBasicInfo({
    super.key,
    required this.viewModel,
  });

  @override
  State<StepBasicInfo> createState() => _StepBasicInfoState();
}

class _StepBasicInfoState extends State<StepBasicInfo> {
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.viewModel.name);
    _dosageController = TextEditingController(
      text: widget.viewModel.dosageValue > 0
          ? (widget.viewModel.dosageValue.truncateToDouble() == widget.viewModel.dosageValue
              ? widget.viewModel.dosageValue.toInt().toString()
              : widget.viewModel.dosageValue.toString())
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant StepBasicInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_nameController.text != widget.viewModel.name) {
      _nameController.text = widget.viewModel.name;
    }
    final formattedDosage = widget.viewModel.dosageValue > 0
        ? (widget.viewModel.dosageValue.truncateToDouble() == widget.viewModel.dosageValue
            ? widget.viewModel.dosageValue.toInt().toString()
            : widget.viewModel.dosageValue.toString())
        : '';
    if (_dosageController.text != formattedDosage) {
      _dosageController.text = formattedDosage;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Photo upload placeholder
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color: AppColors.outlineVariant,
              style: BorderStyle.solid,
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () {
              // Photo selection
            },
            borderRadius: AppRadius.radiusXl,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_a_photo,
                  size: 36,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add Pill Photo',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Medicine Name
        CustomTextField(
          label: 'Medicine Name',
          hintText: 'e.g., Amoxicillin',
          controller: _nameController,
          prefixIcon: const Icon(Icons.medication, color: AppColors.onSurfaceVariant),
          onChanged: (val) => viewModel.name = val,
        ),
        const SizedBox(height: 16),

        // Dosage Amount & Unit
        Text(
          'Dosage',
          style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomTextField(
                hintText: 'Amount',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _dosageController,
                onChanged: (val) {
                  viewModel.dosageValue = double.tryParse(val) ?? 0.0;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: viewModel.dosageUnit,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceVariant),
                    items: const [
                      DropdownMenuItem(value: 'mg', child: Text('mg')),
                      DropdownMenuItem(value: 'ml', child: Text('ml')),
                      DropdownMenuItem(value: 'tablet', child: Text('tab')),
                      DropdownMenuItem(value: 'capsule', child: Text('cap')),
                      DropdownMenuItem(value: 'drops', child: Text('drops')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        viewModel.dosageUnit = val;
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Form Factor Selection
        Text(
          'Pill Form Factor',
          style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['tablet', 'capsule', 'liquid', 'drops', 'injection'].map((form) {
            final isSelected = viewModel.formFactor == form;
            return ChoiceChip(
              label: Text(form[0].toUpperCase() + form.substring(1)),
              selected: isSelected,
              selectedColor: AppColors.primaryContainer.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected) {
                  viewModel.formFactor = form;
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
