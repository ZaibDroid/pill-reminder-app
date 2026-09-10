import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../custom_widgets/primary_button.dart';
import '../../../custom_widgets/secondary_button.dart';

class ExportReportButton extends StatelessWidget {
  final VoidCallback? onShare;
  final VoidCallback? onPreview;
  final VoidCallback? onExport;
  final bool isLoading;

  const ExportReportButton({
    super.key,
    this.onShare,
    this.onPreview,
    this.onExport,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
            child: Text(
              'Export Health Report (PDF)',
              style: AppTextStyles.headlineSm.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          PrimaryButton(
            text: 'Share Health Report (PDF)',
            icon: Icons.share_rounded,
            isLoading: isLoading,
            onPressed: isLoading ? null : (onShare ?? onExport),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            text: 'Preview & Print Report (PDF)',
            icon: Icons.picture_as_pdf_rounded,
            borderColor: AppColors.primary,
            textColor: AppColors.primary,
            onPressed: isLoading ? null : (onPreview ?? onExport),
          ),
        ],
      ),
    );
  }
}
