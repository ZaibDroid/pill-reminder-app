import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/emergency_contact.dart';
import '../../../custom_widgets/custom_text_field.dart';
import '../../../custom_widgets/primary_button.dart';

class AddEditContactDialog extends StatefulWidget {
  final EmergencyContact? contact;
  final FutureOr<void> Function({
    required String fullName,
    required String phoneNumber,
    String? relationship,
    String? email,
    bool isPrimary,
  }) onSave;

  const AddEditContactDialog({
    super.key,
    this.contact,
    required this.onSave,
  });

  @override
  State<AddEditContactDialog> createState() => _AddEditContactDialogState();
}

class _AddEditContactDialogState extends State<AddEditContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _relationshipController;
  late TextEditingController _emailController;
  late bool _isPrimary;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phoneNumber ?? '');
    _relationshipController = TextEditingController(text: widget.contact?.relationship ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    _isPrimary = widget.contact?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      try {
        await widget.onSave(
          fullName: _nameController.text,
          phoneNumber: _phoneController.text,
          relationship: _relationshipController.text,
          email: _emailController.text,
          isPrimary: _isPrimary,
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (_) {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Emergency Contact' : 'Add Emergency Contact',
                  style: AppTextStyles.headlineSm.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Full Name',
                  hintText: 'e.g., Dr. Sarah Mitchell',
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Phone Number',
                  hintText: 'e.g., +1 (555) 234-5678',
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    final digits = val.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 3) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Relationship',
                  hintText: 'e.g., Primary Physician, Daughter, Caregiver',
                  controller: _relationshipController,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Email (Optional)',
                  hintText: 'e.g., contact@example.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set as Primary Contact', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Highlighted for immediate emergency access', style: TextStyle(fontSize: 12)),
                  value: _isPrimary,
                  activeThumbColor: AppColors.primary,
                  onChanged: _isSaving ? null : (val) => setState(() => _isPrimary = val),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Save',
                        height: 48,
                        isLoading: _isSaving,
                        onPressed: _isSaving ? null : _handleSave,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
