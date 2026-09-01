import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pill_reminder_app/app/locator.dart';
import 'package:pill_reminder_app/core/constants/app_colors.dart';
import 'package:pill_reminder_app/core/constants/app_radius.dart';
import 'package:pill_reminder_app/core/constants/app_text_styles.dart';
import 'package:pill_reminder_app/core/models/emergency_contact.dart';
import 'package:pill_reminder_app/ui/custom_widgets/custom_app_bar.dart';
import 'package:pill_reminder_app/ui/custom_widgets/empty_state_widget.dart';
import 'package:pill_reminder_app/ui/custom_widgets/error_state_widget.dart';
import 'package:pill_reminder_app/ui/custom_widgets/loading_widget.dart';
import 'package:pill_reminder_app/ui/viewmodels/emergency_viewmodel.dart';
import 'widgets/add_edit_contact_dialog.dart';
import 'widgets/emergency_contact_card.dart';
import 'widgets/emergency_header.dart';
import 'widgets/lock_screen_setting_card.dart';

class EmergencyContactsScreen extends StatelessWidget {
  final EmergencyViewModel? viewModel;

  const EmergencyContactsScreen({super.key, this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel != null) {
      return ChangeNotifierProvider<EmergencyViewModel>.value(
        value: viewModel!,
        child: const _EmergencyContactsContent(),
      );
    }
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

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 96),
        children: [
          const EmergencyHeader(),
          const SizedBox(height: 12),
          LockScreenSettingCard(
            isEnabled: viewModel.showOnLockScreen,
            onToggle: viewModel.toggleShowOnLockScreen,
          ),
          const SizedBox(height: 16),
          if (viewModel.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: EmptyStateWidget(
                title: 'No Emergency Contacts',
                message: 'Add trusted family members, caregivers, or doctors for quick access during an emergency.',
                icon: Icons.contact_emergency_outlined,
                buttonText: 'Add Emergency Contact',
                onButtonPressed: () => _showAddDialog(context, viewModel),
              ),
            )
          else ...[
            if (viewModel.primaryContact != null) ...[
              EmergencyContactCard(
                contact: viewModel.primaryContact!,
                onCall: () => viewModel.makePhoneCall(viewModel.primaryContact!.phoneNumber),
                onSms: () => viewModel.sendEmergencySms(
                  viewModel.primaryContact!.phoneNumber,
                  message: 'Hello, this is an urgent message from MediAlert.',
                ),
                onEdit: () => _showEditDialog(context, viewModel, viewModel.primaryContact!),
                onDelete: () => viewModel.deleteContact(viewModel.primaryContact!.id),
                onTogglePrimary: () => viewModel.unsetPrimaryContact(viewModel.primaryContact!.id),
              ),
            ],
            ...viewModel.secondaryContacts.map(
              (c) => EmergencyContactCard(
                contact: c,
                onCall: () => viewModel.makePhoneCall(c.phoneNumber),
                onSms: () => viewModel.sendEmergencySms(
                  c.phoneNumber,
                  message: 'Hello, this is an urgent message from MediAlert.',
                ),
                onEdit: () => _showEditDialog(context, viewModel, c),
                onDelete: () => viewModel.deleteContact(c.id),
                onTogglePrimary: () => viewModel.setPrimaryContact(c.id),
              ),
            ),
            const SizedBox(height: 8),
            _buildAddContactButton(context, viewModel),
          ],
        ],
      ),
    );
  }

  Widget _buildAddContactButton(BuildContext context, EmergencyViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 90,
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
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add, color: AppColors.primary, size: 20),
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
        }) async {
          try {
            await viewModel.addContact(
              fullName: fullName,
              phoneNumber: phoneNumber,
              relationship: relationship,
              email: email,
              isPrimary: isPrimary,
            );
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add contact: $e')),
              );
            }
            rethrow;
          }
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, EmergencyViewModel viewModel, EmergencyContact contact) {
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
        }) async {
          try {
            contact.fullName = fullName;
            contact.phoneNumber = phoneNumber;
            contact.relationship = relationship;
            contact.email = email;
            contact.isPrimary = isPrimary;
            await viewModel.updateContact(contact);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update contact: $e')),
              );
            }
            rethrow;
          }
        },
      ),
    );
  }
}
