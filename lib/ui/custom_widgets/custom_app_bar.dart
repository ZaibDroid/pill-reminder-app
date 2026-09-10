import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    Widget? leftWidget = leading;
    if (leftWidget == null && showBackButton) {
      leftWidget = IconButton(
        icon: Icon(Icons.arrow_back, color: primaryColor),
        onPressed: onBackButtonPressed ?? () => Navigator.of(context).pop(),
      );
    }

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      title: Text(
        title,
        style: AppTextStyles.displayLg.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: primaryColor,
        ),
      ),
      leading: leftWidget,
      actions: actions ??
          [
            if (showEmergencyShortcut)
              IconButton(
                icon: Icon(Icons.contact_emergency_rounded, color: primaryColor),
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
