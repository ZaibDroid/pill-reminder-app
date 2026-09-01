import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/locator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../custom_widgets/custom_app_bar.dart';
import '../../custom_widgets/error_state_widget.dart';
import '../../custom_widgets/loading_widget.dart';
import '../../viewmodels/emergency_viewmodel.dart';
import 'widgets/add_edit_contact_dialog.dart';
import 'widgets/emergency_contact_card.dart';
import 'widgets/emergency_header.dart';
import 'widgets/lock_screen_setting_card.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => locator<EmergencyViewModel>()..loadContacts(),
      child: const _EmergencyContactsContent(),
    );
  }
}

class _EmergencyContactsContent extends StatelessWidget {
  const _EmergencyContactsContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EmergencyViewModel>();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'MediAlert',
        showBackButton: true,
        showEmergencyShortcut: false,
      ),
      body: SafeArea(
        child: _buildBody(context, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, EmergencyViewModel viewModel) {
    if (viewModel.isLoading && viewModel.contacts.isEmpty) {
      return const LoadingWidget();
    }

    if (viewModel.hasError && viewModel.contacts.isEmpty) {
      return ErrorStateWidget(
        message: viewModel.errorMessage ?? 'Failed to load contacts.',
        onRetry: viewModel.loadContacts,
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 96),
      children: [
        const EmergencyHeader(),
        const SizedBox(height: 12),
        LockScreenSettingCard(
          isEnabled: viewModel.showOnLockScreen,
          onToggle: viewModel.toggleShowOnLockScreen,
        ),
        const SizedBox(height: 16),
        if (viewModel.primaryContact != null) ...[
          EmergencyContactCard(
            contact: viewModel.primaryContact!,
            onCall: () => viewModel.makePhoneCall(viewModel.primaryContact!.phoneNumber),
            onEdit: () => _showEditDialog(context, viewModel, viewModel.primaryContact!),
            onDelete: () => viewModel.deleteContact(viewModel.primaryContact!.id),
          ),
        ],
        ...viewModel.secondaryContacts.map(
          (c) => EmergencyContactCard(
            contact: c,
            onCall: () => viewModel.makePhoneCall(c.phoneNumber),
            onEdit: () => _showEditDialog(context, viewModel, c),
            onDelete: () => viewModel.deleteContact(c.id),
          ),
        ),
        const SizedBox(height: 8),
        _buildAddContactButton(context, viewModel),
      ],
    );
  }

  Widget _buildAddContactButton(BuildContext context, EmergencyViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: AppColors.outlineVariant,
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showAddDialog(context, viewModel),
        borderRadius: AppRadius.radiusXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              'Add Emergency Contact',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, EmergencyViewModel viewModel) {
    showDialog(
      context: context,
      builder: (_) => AddEditContactDialog(
        onSave: ({
          required String fullName,
          required String phoneNumber,
          String? relationship,
          String? email,
          bool isPrimary = false,
        }) {
          viewModel.addContact(
            fullName: fullName,
            phoneNumber: phoneNumber,
            relationship: relationship,
            email: email,
            isPrimary: isPrimary,
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, EmergencyViewModel viewModel, contact) {
    showDialog(
      context: context,
      builder: (_) => AddEditContactDialog(
        contact: contact,
        onSave: ({
          required String fullName,
          required String phoneNumber,
          String? relationship,
          String? email,
          bool isPrimary = false,
        }) {
          contact.fullName = fullName;
          contact.phoneNumber = phoneNumber;
          contact.relationship = relationship;
          contact.email = email;
          contact.isPrimary = isPrimary;
          viewModel.updateContact(contact);
        },
      ),
    );
  }
}
