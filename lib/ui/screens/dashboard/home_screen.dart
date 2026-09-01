import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pill_reminder_app/app/locator.dart';
import 'package:pill_reminder_app/ui/custom_widgets/empty_state_widget.dart';
import 'package:pill_reminder_app/ui/custom_widgets/error_state_widget.dart';
import 'package:pill_reminder_app/ui/custom_widgets/loading_widget.dart';
import 'package:pill_reminder_app/ui/screens/dashboard/widgets/adherence_card.dart';
import 'package:pill_reminder_app/ui/screens/dashboard/widgets/date_selector.dart';
import 'package:pill_reminder_app/ui/screens/dashboard/widgets/dose_timeline.dart';
import 'package:pill_reminder_app/ui/screens/dashboard/widgets/home_fab.dart';
import 'package:pill_reminder_app/ui/screens/dashboard/widgets/home_header.dart';
import 'package:pill_reminder_app/ui/viewmodels/home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  final HomeViewModel? viewModel;

  const HomeScreen({super.key, this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel != null) {
      return ChangeNotifierProvider<HomeViewModel>.value(
        value: viewModel!,
        child: const _HomeScreenContent(),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => locator<HomeViewModel>()..loadTodayTimeline(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HomeHeader(
              onEmergencyTap: () {
                Navigator.of(context).pushNamed('/emergency');
              },
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: viewModel.refresh,
                child: _buildBody(context, viewModel),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: HomeFab(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/add_medicine');
          if (result == true) {
            viewModel.refresh();
          }
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.isLoading && viewModel.timelineItems.isEmpty) {
      return const LoadingWidget();
    }

    if (viewModel.hasError && viewModel.timelineItems.isEmpty) {
      return ErrorStateWidget(
        message: viewModel.errorMessage ?? 'Failed to load schedule.',
        onRetry: viewModel.refresh,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 96),
      children: [
        // 1. Interactive Calendar Date Strip
        DateSelector(
          selectedDate: viewModel.selectedDate,
          onDateSelected: (date) {
            viewModel.selectDate(date);
          },
        ),
        const SizedBox(height: 16),

        // 2. Adherence Progress Card
        AdherenceCard(
          adherenceRate: viewModel.adherenceRate,
          takenDoses: viewModel.takenDosesCount,
          totalDoses: viewModel.totalDosesCount,
          motivationalMessage: viewModel.adherenceMotivationalMessage,
        ),
        const SizedBox(height: 16),

        // 3. Doses Timeline or Empty State
        if (viewModel.timelineItems.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: EmptyStateWidget(
              title: 'No Medications Today',
              message: 'You have no scheduled doses for this day.',
              buttonText: 'Add Medication',
              onButtonPressed: () async {
                final result = await Navigator.of(context).pushNamed('/add_medicine');
                if (result == true) {
                  viewModel.refresh();
                }
              },
            ),
          )
        else
          DoseTimeline(
            groupedDoses: viewModel.groupedTimelineItems,
            onTakeDose: (dose) async {
              await viewModel.markAsTaken(dose);
            },
            onSkipDose: (dose) async {
              await viewModel.skipDose(dose);
            },
            onCardTap: (dose) {
              Navigator.of(context).pushNamed(
                '/medicine_details',
                arguments: dose.medicine,
              );
            },
          ),
      ],
    );
  }
}
