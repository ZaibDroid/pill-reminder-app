import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/locator.dart';
import '../../app/routes.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/alarm_service.dart';
import '../custom_widgets/app_bottom_nav_bar.dart';
import '../viewmodels/history_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/reports_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'dashboard/home_screen.dart';
import 'history/history_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  final int initialTab;

  const MainShell({super.key, this.initialTab = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  HomeViewModel? _homeViewModel;
  HistoryViewModel? _historyViewModel;
  ReportsViewModel? _reportsViewModel;
  SettingsViewModel? _settingsViewModel;
  Timer? _foregroundAlarmCheckTimer;

  HomeViewModel get _effectiveHomeViewModel =>
      _homeViewModel ??= (locator.isRegistered<HomeViewModel>() ? (locator<HomeViewModel>()..loadTodayTimeline()) : HomeViewModel());

  HistoryViewModel get _effectiveHistoryViewModel =>
      _historyViewModel ??= (locator.isRegistered<HistoryViewModel>() ? (locator<HistoryViewModel>()..loadHistoryForDate(DateTime.now())) : HistoryViewModel());

  ReportsViewModel get _effectiveReportsViewModel =>
      _reportsViewModel ??= (locator.isRegistered<ReportsViewModel>() ? (locator<ReportsViewModel>()..loadMonthlyReports()) : ReportsViewModel());

  SettingsViewModel get _effectiveSettingsViewModel =>
      _settingsViewModel ??= (locator.isRegistered<SettingsViewModel>() ? (locator<SettingsViewModel>()..loadSettings()) : SettingsViewModel());

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _initViewModels();
    _startForegroundAlarmMonitor();
  }

  void _startForegroundAlarmMonitor() {
    _foregroundAlarmCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!mounted) return;
      if (locator.isRegistered<AlarmService>()) {
        final dueMed = await locator<AlarmService>().checkForDueMedicineNow();
        if (dueMed != null && mounted) {
          Navigator.of(context).pushNamed(
            AppRoutes.alarm,
            arguments: dueMed,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _foregroundAlarmCheckTimer?.cancel();
    super.dispose();
  }

  void _initViewModels() {
    _homeViewModel = locator.isRegistered<HomeViewModel>() ? (locator<HomeViewModel>()..loadTodayTimeline()) : HomeViewModel();
    _historyViewModel = locator.isRegistered<HistoryViewModel>() ? (locator<HistoryViewModel>()..loadHistoryForDate(DateTime.now())) : HistoryViewModel();
    _reportsViewModel = locator.isRegistered<ReportsViewModel>() ? (locator<ReportsViewModel>()..loadMonthlyReports()) : ReportsViewModel();
    _settingsViewModel = locator.isRegistered<SettingsViewModel>() ? (locator<SettingsViewModel>()..loadSettings()) : SettingsViewModel();
  }

  void _onAddMedicine() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.addMedicine);
    if (result == true && mounted) {
      await _effectiveHomeViewModel.refresh();
      await _effectiveHistoryViewModel.refresh();
      await _effectiveReportsViewModel.loadMonthlyReports();
      await _effectiveSettingsViewModel.loadSettings();
      setState(() {});
    }
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) {
      if (index == 0) _effectiveHomeViewModel.refresh();
      if (index == 1) _effectiveHistoryViewModel.refresh();
      if (index == 2) _effectiveReportsViewModel.loadMonthlyReports();
      if (index == 3) _effectiveSettingsViewModel.loadSettings();
    } else {
      setState(() {
        _currentIndex = index;
      });
      if (index == 0) _effectiveHomeViewModel.refresh();
      if (index == 1) _effectiveHistoryViewModel.refresh();
      if (index == 2) _effectiveReportsViewModel.loadMonthlyReports();
      if (index == 3) _effectiveSettingsViewModel.loadSettings();
    }
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXl,
        ),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.exit_to_app_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        title: Text(
          'Exit MediAlert?',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineSm.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to exit the application?',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMd.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
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
                      color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(false),
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
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text(
                    'Exit',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return;
        }
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit == true) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(viewModel: _effectiveHomeViewModel),
            HistoryScreen(viewModel: _effectiveHistoryViewModel),
            ReportsScreen(viewModel: _effectiveReportsViewModel),
            SettingsScreen(viewModel: _effectiveSettingsViewModel),
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _currentIndex,
          onTabSelected: _onTabSelected,
          onAddPressed: _onAddMedicine,
        ),
      ),
    );
  }
}
