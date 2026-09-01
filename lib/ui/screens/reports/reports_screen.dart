import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pill_reminder_app/app/locator.dart';
import 'package:pill_reminder_app/ui/custom_widgets/custom_app_bar.dart';
import 'package:pill_reminder_app/ui/custom_widgets/error_state_widget.dart';
import 'package:pill_reminder_app/ui/custom_widgets/loading_widget.dart';
import 'package:pill_reminder_app/ui/screens/reports/widgets/adherence_heatmap_calendar.dart';
import 'package:pill_reminder_app/ui/screens/reports/widgets/adherence_metrics_grid.dart';
import 'package:pill_reminder_app/ui/screens/reports/widgets/dose_distribution_chart.dart';
import 'package:pill_reminder_app/ui/screens/reports/widgets/export_report_button.dart';
import 'package:pill_reminder_app/ui/screens/reports/widgets/reports_header.dart';
import 'package:pill_reminder_app/ui/viewmodels/reports_viewmodel.dart';

class ReportsScreen extends StatelessWidget {
  final ReportsViewModel? viewModel;

  const ReportsScreen({super.key, this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel != null) {
      return ChangeNotifierProvider<ReportsViewModel>.value(
        value: viewModel!,
        child: const _ReportsScreenContent(),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => locator<ReportsViewModel>()..loadMonthlyReports(),
      child: const _ReportsScreenContent(),
    );
  }
}

class _ReportsScreenContent extends StatelessWidget {
  const _ReportsScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReportsViewModel>();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'MediAlert',
      ),
      body: SafeArea(
        child: _buildBody(context, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReportsViewModel viewModel) {
    if (viewModel.isLoading && viewModel.totalScheduledCount == 0 && viewModel.monthLogs.isEmpty) {
      return const LoadingWidget();
    }

    if (viewModel.hasError && viewModel.totalScheduledCount == 0 && viewModel.monthLogs.isEmpty) {
      return ErrorStateWidget(
        message: viewModel.errorMessage ?? 'Failed to load report data.',
        onRetry: viewModel.loadMonthlyReports,
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.loadMonthlyReports,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 96),
        children: [
          ReportsHeader(currentMonth: viewModel.currentMonth),
          const SizedBox(height: 12),
          DoseDistributionChart(
            takenPercentage: viewModel.takenPercentage,
            skippedPercentage: viewModel.skippedPercentage,
            missedPercentage: viewModel.missedPercentage,
          ),
          const SizedBox(height: 16),
          AdherenceMetricsGrid(
            adherenceRate: viewModel.adherenceRate,
            longestStreak: viewModel.longestStreakDays,
            takenDoses: viewModel.takenCount,
            totalDoses: viewModel.totalScheduledCount,
          ),
          const SizedBox(height: 16),
          AdherenceHeatmapCalendar(
            currentMonth: viewModel.currentMonth,
            dailyAdherenceRates: viewModel.dailyAdherenceRates,
            dailyDoseCounts: viewModel.dailyDoseCounts,
          ),
          const SizedBox(height: 24),
          ExportReportButton(
            isLoading: viewModel.isExporting,
            onExport: () async {
              await viewModel.exportPdfReport();
            },
          ),
        ],
      ),
    );
  }
}
