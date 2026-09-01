import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onEmergencyPressed;
  final bool showEmergencyShortcut;

  const CustomAppBar({
    super.key,
    this.title = 'MediAlert',
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.onBackButtonPressed,
    this.onEmergencyPressed,
    this.showEmergencyShortcut = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget? leftWidget = leading;
    if (leftWidget == null) {
      if (showBackButton) {
        leftWidget = IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: onBackButtonPressed ?? () => Navigator.of(context).pop(),
        );
      } else {
        leftWidget = IconButton(
          icon: const Icon(Icons.medical_services, color: AppColors.primary),
          onPressed: () {},
        );
      }
    }

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      title: Text(
        title,
        style: AppTextStyles.displayLg.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      leading: leftWidget,
      actions: actions ??
          [
            if (showEmergencyShortcut)
              IconButton(
                icon: const Icon(Icons.emergency, color: AppColors.primary),
                tooltip: 'Emergency Contacts',
                onPressed: onEmergencyPressed ??
                    () {
                      Navigator.of(context).pushNamed('/emergency');
                    },
              ),
            const SizedBox(width: 8),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
