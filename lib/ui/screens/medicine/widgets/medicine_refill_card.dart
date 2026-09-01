import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/medicine.dart';

class MedicineRefillCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineRefillCard({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = medicine.currentStock <= medicine.lowStockThreshold;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: isLowStock ? AppColors.errorContainer : AppColors.surfaceContainerHigh,
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
                    color: isLowStock ? AppColors.error : AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Supply & Refill',
                    style: AppTextStyles.headlineSm.copyWith(
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
              color: isLowStock ? AppColors.error : AppColors.onSurface,
              fontWeight: isLowStock ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Refill reminder set when stock reaches ${medicine.lowStockThreshold} doses.',
            style: AppTextStyles.labelSm,
          ),
        ],
      ),
    );
  }
}
