import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill_reminder_app/app/locator.dart';
import 'package:pill_reminder_app/core/models/user_settings.dart';
import 'package:pill_reminder_app/core/repositories/user_settings_repository.dart';
import 'package:pill_reminder_app/ui/screens/splash/splash_screen.dart';

class MockUserSettingsRepository extends Fake implements UserSettingsRepository {
  UserSettings settings = UserSettings()
    ..isFirstTimeUser = false
    ..pinHash = null;

  @override
  Future<UserSettings> getOrCreateSettings() async {
    return settings;
  }
}

Widget _buildTestApp({
  required GlobalKey<NavigatorState> navKey,
  required Widget homeWidget,
  required Widget onboardingWidget,
  required Widget appLockWidget,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => MaterialApp(
      navigatorKey: navKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => onboardingWidget);
          case '/app_lock':
            return MaterialPageRoute(builder: (_) => appLockWidget);
          case '/home':
            return MaterialPageRoute(builder: (_) => homeWidget);
          default:
            return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Unknown')));
        }
      },
    ),
  );
}

void main() {
  late MockUserSettingsRepository mockUserSettingsRepo;
  late GlobalKey<NavigatorState> navKey;

  setUp(() {
    navKey = GlobalKey<NavigatorState>();
    if (locator.isRegistered<UserSettingsRepository>()) {
      locator.unregister<UserSettingsRepository>();
    }
    mockUserSettingsRepo = MockUserSettingsRepository();
    locator.registerLazySingleton<UserSettingsRepository>(() => mockUserSettingsRepo);
  });

  tearDown(() {
    if (locator.isRegistered<UserSettingsRepository>()) {
      locator.unregister<UserSettingsRepository>();
    }
  });

  group('SplashScreen Widget & Navigation Tests', () {
    testWidgets('Renders branding title, subtitle, and logo on launch', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          navKey: navKey,
          homeWidget: const Scaffold(body: Text('Home Destination')),
          onboardingWidget: const Scaffold(body: Text('Onboarding Destination')),
          appLockWidget: const Scaffold(body: Text('AppLock Destination')),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('MediAlert'), findsOneWidget);
      expect(find.text('Your Reliable Health Companion'), findsOneWidget);
      expect(find.byType(SplashScreen), findsOneWidget);

      // Flush remaining timer to cleanly finish test
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();
    });

    testWidgets('Navigates to Onboarding for first time users', (tester) async {
      mockUserSettingsRepo.settings = UserSettings()
        ..isFirstTimeUser = true
        ..pinHash = null;

      await tester.pumpWidget(
        _buildTestApp(
          navKey: navKey,
          homeWidget: const Scaffold(body: Text('Home Destination')),
          onboardingWidget: const Scaffold(body: Text('Onboarding Destination')),
          appLockWidget: const Scaffold(body: Text('AppLock Destination')),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Advance through animation and destination delay
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      expect(find.text('Onboarding Destination'), findsOneWidget);
    });

    testWidgets('Navigates to App Lock when PIN is set', (tester) async {
      mockUserSettingsRepo.settings = UserSettings()
        ..isFirstTimeUser = false
        ..pinHash = '1234';

      await tester.pumpWidget(
        _buildTestApp(
          navKey: navKey,
          homeWidget: const Scaffold(body: Text('Home Destination')),
          onboardingWidget: const Scaffold(body: Text('Onboarding Destination')),
          appLockWidget: const Scaffold(body: Text('AppLock Destination')),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Advance through animation and destination delay
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      expect(find.text('AppLock Destination'), findsOneWidget);
    });

    testWidgets('Navigates to Home for returning users without PIN', (tester) async {
      mockUserSettingsRepo.settings = UserSettings()
        ..isFirstTimeUser = false
        ..pinHash = null;

      await tester.pumpWidget(
        _buildTestApp(
          navKey: navKey,
          homeWidget: const Scaffold(body: Text('Home Destination')),
          onboardingWidget: const Scaffold(body: Text('Onboarding Destination')),
          appLockWidget: const Scaffold(body: Text('AppLock Destination')),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Advance through animation and destination delay
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      expect(find.text('Home Destination'), findsOneWidget);
    });
  });
}
