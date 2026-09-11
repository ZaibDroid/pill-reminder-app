import 'package:flutter/material.dart';
import '../core/models/medicine.dart';
import '../ui/screens/alarm/active_alarm_screen.dart';
import '../ui/screens/app_lock/app_lock_screen.dart';
import '../ui/screens/emergency/emergency_contacts_screen.dart';
import '../ui/screens/main_shell.dart';
import '../ui/screens/medicine/add_medicine_screen.dart';
import '../ui/screens/medicine/medicine_details_screen.dart';
import '../ui/screens/medicine/medicine_list_screen.dart';
import '../ui/screens/onboarding/onboarding_screen.dart';
import '../ui/screens/splash/splash_screen.dart';

class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String appLock = '/app_lock';
  static const String home = '/home';
  static const String medicineList = '/medicine_list';
  static const String medicineDetails = '/medicine_details';
  static const String addMedicine = '/add_medicine';
  static const String emergency = '/emergency';
  static const String alarm = '/alarm';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildFadeRoute(const SplashScreen(), settings);

      case onboarding:
        return _buildFadeRoute(const OnboardingScreen(), settings);

      case appLock:
        return _buildFadeRoute(
          AppLockScreen(
            onUnlockSuccess: () {
              Navigator.of(navigatorKey.currentContext ?? AppRoutes.navigatorKey.currentState!.context)
                  .pushReplacementNamed(home);
            },
          ),
          settings,
        );

      case home:
        return _buildFadeRoute(const MainShell(), settings);

      case medicineList:
        return MaterialPageRoute(
          builder: (_) => const MedicineListScreen(),
        );

      case medicineDetails:
        final medicine = settings.arguments as Medicine;
        return MaterialPageRoute(
          builder: (_) => MedicineDetailsScreen(medicine: medicine),
        );

      case addMedicine:
        final existingMedicine = settings.arguments as Medicine?;
        return MaterialPageRoute(
          builder: (_) => AddMedicineScreen(existingMedicine: existingMedicine),
        );

      case emergency:
        return MaterialPageRoute(
          builder: (_) => const EmergencyContactsScreen(),
        );

      case alarm:
        Medicine? medicine;
        int? medicineId;
        int? reminderTimeId;
        if (settings.arguments is Medicine) {
          medicine = settings.arguments as Medicine;
        } else if (settings.arguments is Map<String, dynamic>) {
          final map = settings.arguments as Map<String, dynamic>;
          medicine = map['medicine'] as Medicine?;
          medicineId = map['medicineId'] as int?;
          reminderTimeId = map['reminderTimeId'] as int?;
        }
        return MaterialPageRoute(
          builder: (_) => ActiveAlarmScreen(
            medicine: medicine,
            medicineId: medicineId,
            reminderTimeId: reminderTimeId,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _buildFadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
