import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pill_reminder_app/core/models/user_settings.dart';
import 'package:pill_reminder_app/core/repositories/user_settings_repository.dart';
import 'package:pill_reminder_app/ui/custom_widgets/loading_indicator.dart';
import 'package:pill_reminder_app/ui/screens/app_lock/app_lock_screen.dart';
import 'package:pill_reminder_app/ui/screens/app_lock/widgets/pin_dots_indicator.dart';
import 'package:pill_reminder_app/ui/viewmodels/app_lock_viewmodel.dart';

class MockUserSettingsRepository extends Fake implements UserSettingsRepository {
  UserSettings settings = UserSettings()..pinHash = '1234';

  @override
  Future<UserSettings> getOrCreateSettings() async {
    return settings;
  }
}

class MockLocalAuthentication extends Fake implements LocalAuthentication {
  @override
  Future<bool> get canCheckBiometrics async => false;
}

Widget _buildTestWrapper(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  late MockUserSettingsRepository mockRepo;
  late MockLocalAuthentication mockAuth;
  late AppLockViewModel viewModel;

  setUp(() {
    mockRepo = MockUserSettingsRepository();
    mockAuth = MockLocalAuthentication();
    viewModel = AppLockViewModel(
      userSettingsRepository: mockRepo,
      localAuth: mockAuth,
    );
  });

  group('AppLockScreen Widget Tests', () {
    testWidgets('Displays normal pin dots and keypad when idle', (tester) async {
      await tester.pumpWidget(
        _buildTestWrapper(
          AppLockScreen(
            viewModel: viewModel,
            onUnlockSuccess: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Enter PIN to Unlock'), findsOneWidget);
      expect(find.byType(PinDotsIndicator), findsOneWidget);
      expect(find.byType(AppLoadingIndicator), findsNothing);
      expect(find.byKey(const ValueKey('keypad_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('keypad_2')), findsOneWidget);
    });

    testWidgets('Entering correct 4-digit PIN triggers loading spinner and unlocks successfully', (tester) async {
      bool unlocked = false;

      await tester.pumpWidget(
        _buildTestWrapper(
          AppLockScreen(
            viewModel: viewModel,
            onUnlockSuccess: () => unlocked = true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Enter 1 2 3 4
      await tester.tap(find.byKey(const ValueKey('keypad_1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('keypad_2')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('keypad_3')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('keypad_4')));
      await tester.pump();

      // Should show AppLoadingIndicator and SpinKitSquareCircle during verification
      expect(find.byType(AppLoadingIndicator), findsWidgets);
      expect(find.byType(SpinKitSquareCircle), findsWidgets);

      // Finish async delayed verification
      await tester.pump(const Duration(milliseconds: 500));

      expect(unlocked, isTrue);
    });

    testWidgets('Entering incorrect 4-digit PIN shows error and resets spinner', (tester) async {
      bool unlocked = false;

      await tester.pumpWidget(
        _buildTestWrapper(
          AppLockScreen(
            viewModel: viewModel,
            onUnlockSuccess: () => unlocked = true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Enter 9 9 9 9 (incorrect)
      await tester.tap(find.byKey(const ValueKey('keypad_9')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('keypad_9')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('keypad_9')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('keypad_9')));
      await tester.pump();

      // Shows loading during verification
      expect(find.byType(AppLoadingIndicator), findsWidgets);

      // Advance clock past verification delay
      await tester.pump(const Duration(milliseconds: 500));

      // Spinner should disappear and error message should appear
      expect(find.byType(AppLoadingIndicator), findsNothing);
      expect(find.text('Incorrect PIN. Please try again.'), findsOneWidget);
      expect(unlocked, isFalse);
    });
  });
}
