import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/locator.dart';
import '../../custom_widgets/custom_app_bar.dart';
import '../../custom_widgets/error_state_widget.dart';
import '../../custom_widgets/loading_widget.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'widgets/alarm_sound_selection_dialog.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_navigation_tile.dart';
import 'widgets/settings_profile_card.dart';
import 'widgets/settings_section_card.dart';
import 'widgets/settings_switch_tile.dart';
import 'widgets/theme_selection_dialog.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsViewModel? viewModel;

  const SettingsScreen({super.key, this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel != null) {
      return ChangeNotifierProvider<SettingsViewModel>.value(
        value: viewModel!,
        child: const _SettingsScreenContent(),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => locator<SettingsViewModel>()..loadSettings(),
      child: const _SettingsScreenContent(),
    );
  }
}

class _SettingsScreenContent extends StatelessWidget {
  const _SettingsScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'MediAlert',
      ),
      body: SafeArea(
        child: _buildBody(context, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SettingsViewModel viewModel) {
    if (viewModel.isLoading && viewModel.settings == null) {
      return const LoadingWidget();
    }

    if (viewModel.hasError && viewModel.settings == null) {
      return ErrorStateWidget(
        message: viewModel.errorMessage ?? 'Failed to load settings.',
        onRetry: viewModel.loadSettings,
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 96),
      children: [
        const SettingsHeader(),
        const SizedBox(height: 12),
        SettingsProfileCard(
          userName: viewModel.userName,
          patientId: viewModel.patientId,
          profileImagePath: viewModel.profileImagePath,
          onEdit: () => _showEditProfileDialog(context, viewModel),
        ),
        const SizedBox(height: 8),

        // Medication Management
        SettingsSectionCard(
          title: 'Medications',
          children: [
            SettingsNavigationTile(
              icon: Icons.medication_rounded,
              title: 'Manage Medications',
              subtitle: 'View, edit, or remove all medications',
              onTap: () async {
                await Navigator.of(context).pushNamed('/medicine_list');
                await viewModel.loadSettings();
              },
            ),
          ],
        ),

        // Notifications & Alerts
        SettingsSectionCard(
          title: 'Notifications & Alerts',
          children: [
            SettingsSwitchTile(
              icon: Icons.notifications_active,
              title: 'High-Priority Alarms',
              subtitle: 'Override silent mode for critical doses',
              value: viewModel.isHighPriorityAlarmEnabled,
              onChanged: (val) => viewModel.setHighPriorityAlarm(val),
            ),
            SettingsNavigationTile(
              icon: Icons.notifications_active_rounded,
              title: 'Notification Sound',
              subtitle: viewModel.notificationSound,
              onTap: () {
                _showSoundPicker(context, viewModel);
              },
            ),
            SettingsNavigationTile(
              icon: Icons.notification_important_rounded,
              title: 'Test Alarm & Vibration',
              subtitle: 'Trigger a test alarm immediately',
              onTap: () async {
                await viewModel.triggerTestAlarm();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test alarm triggered! Check notification and vibration.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
            SettingsNavigationTile(
              icon: Icons.sync_rounded,
              title: 'Resync All Reminders',
              subtitle: 'Re-align all medicine alarms with device clock',
              onTap: () async {
                final count = await viewModel.syncAllAlarms();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully resynced $count reminder alarms!'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
            SettingsNavigationTile(
              icon: Icons.palette,
              title: 'App Theme',
              subtitle: viewModel.themeMode.toUpperCase(),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => ThemeSelectionDialog(
                    currentTheme: viewModel.themeMode,
                    onSelected: (theme) => viewModel.setThemeMode(theme),
                  ),
                );
              },
            ),
          ],
        ),

        // Support
        SettingsSectionCard(
          title: 'Support',
          children: [
            SettingsNavigationTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              onTap: () {},
            ),
            SettingsNavigationTile(
              icon: Icons.info_outline,
              title: 'About MediAlert',
              subtitle: 'Clinical Humanist Edition',
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Version 4.2.1 (Clinical Build)',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _showSoundPicker(BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (_) => AlarmSoundSelectionDialog(
        isNotificationMode: true,
        currentSound: viewModel.notificationSound,
        onSelected: (sound) => viewModel.setNotificationSound(sound),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) => EditProfileDialog(viewModel: viewModel),
    );
  }
}
