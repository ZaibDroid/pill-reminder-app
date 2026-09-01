import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/locator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/medicine.dart';
import '../../custom_widgets/custom_app_bar.dart';
import '../../viewmodels/medicine_viewmodel.dart';
import 'widgets/medicine_info_card.dart';
import 'widgets/medicine_refill_card.dart';
import 'widgets/medicine_schedule_card.dart';

class MedicineDetailsScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailsScreen({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => locator<MedicineViewModel>(),
      child: _MedicineDetailsContent(medicine: medicine),
    );
  }
}

class _MedicineDetailsContent extends StatelessWidget {
  final Medicine medicine;

  const _MedicineDetailsContent({required this.medicine});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MedicineViewModel>();

    return Scaffold(
      appBar: CustomAppBar(
        title: medicine.name,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () async {
              final result = await Navigator.of(context).pushNamed(
                '/add_medicine',
                arguments: medicine,
              );
              if (result == true && context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Medication'),
                  content: Text('Are you sure you want to delete ${medicine.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await viewModel.deleteMedicine(medicine.id);
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          MedicineInfoCard(medicine: medicine),
          const SizedBox(height: 8),
          MedicineScheduleCard(medicine: medicine),
          const SizedBox(height: 8),
          MedicineRefillCard(medicine: medicine),
          if (medicine.prescriptionNotes != null &&
              medicine.prescriptionNotes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainerHigh),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.note_alt, size: 20, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Prescription Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(medicine.prescriptionNotes!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
