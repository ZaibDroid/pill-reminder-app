import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/locator.dart';
import '../../custom_widgets/custom_app_bar.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../custom_widgets/empty_state_widget.dart';
import '../../custom_widgets/error_state_widget.dart';
import '../../custom_widgets/loading_widget.dart';
import '../../viewmodels/medicine_viewmodel.dart';
import 'widgets/medicine_list_item.dart';

class MedicineListScreen extends StatelessWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => locator<MedicineViewModel>()..loadMedicines(),
      child: const _MedicineListContent(),
    );
  }
}

class _MedicineListContent extends StatelessWidget {
  const _MedicineListContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MedicineViewModel>();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Medications',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomTextField(
              hintText: 'Search medications or doctor...',
              prefixIcon: const Icon(Icons.search),
              onChanged: viewModel.setSearchQuery,
            ),
          ),
          Expanded(
            child: _buildList(context, viewModel),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/add_medicine');
          if (result == true) {
            viewModel.loadMedicines();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
      ),
    );
  }

  Widget _buildList(BuildContext context, MedicineViewModel viewModel) {
    if (viewModel.isLoading && viewModel.medicines.isEmpty) {
      return const LoadingWidget();
    }

    if (viewModel.hasError && viewModel.medicines.isEmpty) {
      return ErrorStateWidget(
        message: viewModel.errorMessage ?? 'Failed to load medications.',
        onRetry: viewModel.loadMedicines,
      );
    }

    if (viewModel.medicines.isEmpty) {
      return EmptyStateWidget(
        title: 'No Medications Found',
        message: 'You have not added any medications yet.',
        buttonText: 'Add First Medication',
        onButtonPressed: () async {
          final result = await Navigator.of(context).pushNamed('/add_medicine');
          if (result == true) {
            viewModel.loadMedicines();
          }
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96, top: 4),
      itemCount: viewModel.medicines.length,
      itemBuilder: (context, index) {
        final med = viewModel.medicines[index];
        return MedicineListItem(
          medicine: med,
          onTap: () async {
            final result = await Navigator.of(context).pushNamed(
              '/medicine_details',
              arguments: med,
            );
            if (result == true) {
              viewModel.loadMedicines();
            }
          },
        );
      },
    );
  }
}
