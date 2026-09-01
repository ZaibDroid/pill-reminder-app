import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pill_reminder_app/app/locator.dart';
import 'package:pill_reminder_app/ui/custom_widgets/custom_app_bar.dart';
import 'package:pill_reminder_app/ui/custom_widgets/empty_state_widget.dart';
import 'package:pill_reminder_app/ui/custom_widgets/error_state_widget.dart';
import 'package:pill_reminder_app/ui/custom_widgets/loading_widget.dart';
import 'package:pill_reminder_app/ui/screens/history/widgets/history_calendar_strip.dart';
import 'package:pill_reminder_app/ui/screens/history/widgets/history_dose_item_card.dart';
import 'package:pill_reminder_app/ui/screens/history/widgets/history_header.dart';
import 'package:pill_reminder_app/ui/screens/history/widgets/history_summary_card.dart';
import 'package:pill_reminder_app/ui/viewmodels/history_viewmodel.dart';

class HistoryScreen extends StatelessWidget {
  final HistoryViewModel? viewModel;

  const HistoryScreen({super.key, this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel != null) {
      return ChangeNotifierProvider<HistoryViewModel>.value(
        value: viewModel!,
        child: const _HistoryScreenContent(),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => locator<HistoryViewModel>()..loadHistoryForDate(DateTime.now()),
      child: const _HistoryScreenContent(),
    );
  }
}

class _HistoryScreenContent extends StatelessWidget {
  const _HistoryScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HistoryViewModel>();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'MediAlert',
      ),
      body: SafeArea(
        child: _buildBody(context, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HistoryViewModel viewModel) {
    if (viewModel.isLoading && viewModel.items.isEmpty) {
      return const LoadingWidget();
    }

    if (viewModel.hasError && viewModel.items.isEmpty) {
      return ErrorStateWidget(
        message: viewModel.errorMessage ?? 'Failed to load dose history.',
        onRetry: () => viewModel.loadHistoryForDate(viewModel.selectedDate),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 96),
        children: [
          const HistoryHeader(),
          const SizedBox(height: 12),
          HistorySummaryCard(
            adherenceRate: viewModel.adherenceRate,
            motivationalMessage: viewModel.motivationalMessage,
          ),
          const SizedBox(height: 16),
          HistoryCalendarStrip(
            selectedDate: viewModel.selectedDate,
            onDateSelected: (date) => viewModel.selectDate(date),
            onTodayPressed: () => viewModel.jumpToToday(),
          ),
          const SizedBox(height: 16),
          if (viewModel.items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: EmptyStateWidget(
                title: 'No History for This Day',
                message: 'There were no doses recorded on this date.',
                icon: Icons.history_toggle_off,
              ),
            )
          else
            ...viewModel.items.map((item) => HistoryDoseItemCard(item: item)),
        ],
      ),
    );
  }
}
