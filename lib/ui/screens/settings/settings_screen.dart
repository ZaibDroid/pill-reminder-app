import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/locator.dart';
import '../../custom_widgets/custom_app_bar.dart';
import '../../custom_widgets/error_state_widget.dart';
import '../../custom_widgets/loading_widget.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_navigation_tile.dart';
import 'widgets/settings_profile_card.dart';
import 'widgets/settings_section_card.dart';
import 'widgets/settings_switch_tile.dart';
import 'widgets/theme_selection_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        ),
        const SizedBox(height: 8),

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
              icon: Icons.volume_up,
              title: 'Alarm Sound',
              subtitle: viewModel.alarmSound,
              onTap: () {
                _showSoundPicker(context, viewModel);
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

        // Security & Privacy
        SettingsSectionCard(
          title: 'Security & Privacy',
          children: [
            SettingsSwitchTile(
              icon: Icons.pin,
              title: 'App PIN Lock',
              subtitle: 'Require PIN on launch',
              value: viewModel.isPinLockEnabled,
              onChanged: (val) {
                if (val) {
                  _showSetPinDialog(context, viewModel);
                } else {
                  viewModel.setPin(null);
                }
              },
            ),
            SettingsSwitchTile(
              icon: Icons.fingerprint,
              title: 'Biometric Unlock',
              subtitle: 'Use FaceID or TouchID',
              value: viewModel.isBiometricEnabled,
              onChanged: (val) => viewModel.setBiometric(val),
            ),
          ],
        ),

        // Data Management
        SettingsSectionCard(
          title: 'Data',
          children: [
            SettingsNavigationTile(
              icon: Icons.download,
              title: 'Export Data (JSON)',
              onTap: () async {
                final json = await viewModel.exportDataJson();
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Exported Data (JSON)'),
                      content: SingleChildScrollView(
                        child: SelectableText(json),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            SettingsNavigationTile(
              icon: Icons.backup,
              title: 'Backup to Cloud',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Offline data safely stored on device.')),
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
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Alarm Sound'),
        children: ['Clinical Chime', 'Classic Alarm', 'Gentle Beep', 'Vibrate Only'].map((sound) {
          return SimpleDialogOption(
            onPressed: () {
              viewModel.setAlarmSound(sound);
              Navigator.of(ctx).pop();
            },
            child: Text(sound),
          );
        }).toList(),
      ),
    );
  }

  void _showSetPinDialog(BuildContext context, SettingsViewModel viewModel) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set 4-Digit PIN'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Enter 4 digits'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.length == 4) {
                viewModel.setPin(controller.text);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );
  }
}
