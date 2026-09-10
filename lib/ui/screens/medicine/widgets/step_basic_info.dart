import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  void _showImagePickerModal(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Medicine Photo',
                style: AppTextStyles.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: theme.colorScheme.onPrimaryContainer),
                ),
                title: Text(
                  'Take Photo (Camera)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  widget.viewModel.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library_rounded, color: theme.colorScheme.onSecondaryContainer),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  widget.viewModel.pickImage(ImageSource.gallery);
                },
              ),
              if (widget.viewModel.pillImageLocalPath != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                  ),
                  title: Text(
                    'Remove Photo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    widget.viewModel.removeImage();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasImage = viewModel.pillImageLocalPath != null &&
        File(viewModel.pillImageLocalPath!).existsSync();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Photo upload or preview
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () => _showImagePickerModal(context),
            borderRadius: AppRadius.radiusXl,
            child: hasImage
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.radiusXl,
                        child: Image.file(
                          File(viewModel.pillImageLocalPath!),
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: AppRadius.radiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.edit, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Change Photo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Add Pill Photo',
                        style: AppTextStyles.labelMd.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to take photo or choose from gallery',
                        style: AppTextStyles.labelSm.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
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
          hintText: 'Medicine Name',
          controller: _nameController,
          prefixIcon: Icon(Icons.medication, color: theme.colorScheme.onSurfaceVariant),
          onChanged: (val) => viewModel.name = val,
        ),
        const SizedBox(height: 16),

        // Dosage Amount & Unit
        Text(
          'Dosage',
          style: AppTextStyles.labelMd.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
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
                  color: theme.colorScheme.surface,
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _normalizeUnit(viewModel.dosageUnit),
                    dropdownColor: theme.colorScheme.surface,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurfaceVariant),
                    items: const [
                      DropdownMenuItem(value: 'mg', child: Text('mg')),
                      DropdownMenuItem(value: 'ml', child: Text('ml')),
                      DropdownMenuItem(value: 'tab', child: Text('tab')),
                      DropdownMenuItem(value: 'cap', child: Text('cap')),
                      DropdownMenuItem(value: 'drop', child: Text('drop')),
                      DropdownMenuItem(value: 'mcg', child: Text('mcg')),
                      DropdownMenuItem(value: 'g', child: Text('g')),
                      DropdownMenuItem(value: 'IU', child: Text('IU')),
                      DropdownMenuItem(value: 'puff', child: Text('puff')),
                      DropdownMenuItem(value: 'spray', child: Text('spray')),
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
          style: AppTextStyles.labelMd.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['tablet', 'capsule', 'liquid', 'drops', 'injection'].map((form) {
            final isSelected = viewModel.formFactor.toLowerCase() == form.toLowerCase();
            return ChoiceChip(
              avatar: isSelected
                  ? Icon(Icons.check_rounded, size: 16, color: theme.colorScheme.primary)
                  : null,
              label: Text(form[0].toUpperCase() + form.substring(1)),
              selected: isSelected,
              selectedColor: theme.colorScheme.primaryContainer,
              backgroundColor: theme.colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.3),
                width: isSelected ? 1.5 : 1.0,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

  String _normalizeUnit(String raw) {
    if (raw == 'tablet') return 'tab';
    if (raw == 'capsule') return 'cap';
    if (raw == 'drops') return 'drop';
    const valid = ['mg', 'ml', 'tab', 'cap', 'drop', 'mcg', 'g', 'IU', 'puff', 'spray'];
    return valid.contains(raw) ? raw : 'mg';
  }
}
