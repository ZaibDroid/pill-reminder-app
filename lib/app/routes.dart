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
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );

      case appLock:
        return MaterialPageRoute(
          builder: (ctx) => AppLockScreen(
            onUnlockSuccess: () {
              Navigator.of(ctx).pushReplacementNamed(home);
            },
          ),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const MainShell(),
        );

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
        final medicine = settings.arguments as Medicine?;
        return MaterialPageRoute(
          builder: (_) => ActiveAlarmScreen(medicine: medicine),
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
}
