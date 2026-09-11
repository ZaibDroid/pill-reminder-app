import 'package:flutter/material.dart';
import '../../../../app/locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/medicine.dart';
import '../../../../core/repositories/medicine_repository.dart';

class MedicineRefillCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onStockUpdated;

  const MedicineRefillCard({
    super.key,
    required this.medicine,
    this.onStockUpdated,
  });

  void _showRefillDialog(BuildContext context) {
    final controller = TextEditingController(text: '30');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Refill ${medicine.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current stock: ${medicine.currentStock} remaining',
              style: AppTextStyles.bodyMd,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Add Quantity',
                hintText: 'Enter units to add (e.g. 30)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.add_shopping_cart),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final added = int.tryParse(controller.text) ?? 0;
              if (added > 0) {
                medicine.currentStock += added;
                if (locator.isRegistered<MedicineRepository>()) {
                  await locator<MedicineRepository>().updateMedicine(medicine);
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
                onStockUpdated?.call();
              }
            },
            child: const Text('Add to Stock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowStock = medicine.currentStock <= medicine.lowStockThreshold;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: isLowStock ? theme.colorScheme.error : theme.colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    color: isLowStock ? theme.colorScheme.error : theme.colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Supply & Refill',
                    style: AppTextStyles.headlineSm.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (isLowStock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Text(
                    'Low Stock',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Current Stock: ${medicine.currentStock} remaining',
            style: AppTextStyles.bodyMd.copyWith(
              color: isLowStock ? theme.colorScheme.error : theme.colorScheme.onSurface,
              fontWeight: isLowStock ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Refill reminder set when stock reaches ${medicine.lowStockThreshold} doses.',
            style: AppTextStyles.labelSm.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _showRefillDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Refill Stock'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
