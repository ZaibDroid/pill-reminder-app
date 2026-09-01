import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pill_reminder_app/core/models/user_settings.dart';
import 'package:pill_reminder_app/core/repositories/user_settings_repository.dart';
import 'package:pill_reminder_app/ui/viewmodels/app_lock_viewmodel.dart';

class FakeUserSettingsRepository extends Fake implements UserSettingsRepository {
  UserSettings settings = UserSettings()..pinHash = '1234';

  @override
  Future<UserSettings> getOrCreateSettings() async {
    return settings;
  }
}

class FakeLocalAuthentication extends Fake implements LocalAuthentication {
  bool canAuth = true;
  bool authResult = true;

  @override
  Future<bool> get canCheckBiometrics async => canAuth;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #canCheckBiometrics) {
      return Future.value(canAuth);
    }
    if (invocation.memberName == #authenticate) {
      return Future.value(authResult);
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late FakeUserSettingsRepository mockRepo;
  late FakeLocalAuthentication mockAuth;
  late AppLockViewModel viewModel;

  setUp(() {
    mockRepo = FakeUserSettingsRepository();
    mockAuth = FakeLocalAuthentication();
    viewModel = AppLockViewModel(
      userSettingsRepository: mockRepo,
      localAuth: mockAuth,
    );
  });

  group('AppLockViewModel Tests', () {
    test('Initial state is not loading and pin is empty', () {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.enteredPin, isEmpty);
      expect(viewModel.pinLength, equals(0));
      expect(viewModel.isError, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('appendDigit updates pin up to 4 digits and ignores when full', () {
      viewModel.appendDigit('1');
      viewModel.appendDigit('2');
      viewModel.appendDigit('3');
      expect(viewModel.enteredPin, equals('123'));
      expect(viewModel.pinLength, equals(3));

      viewModel.appendDigit('4');
      expect(viewModel.enteredPin, equals('1234'));
      expect(viewModel.pinLength, equals(4));

      viewModel.appendDigit('5');
      expect(viewModel.enteredPin, equals('1234'));
    });

    test('deleteDigit removes last digit', () {
      viewModel.appendDigit('1');
      viewModel.appendDigit('2');
      viewModel.deleteDigit();
      expect(viewModel.enteredPin, equals('1'));
      expect(viewModel.pinLength, equals(1));
    });

    test('verifyPin transitions loading state and succeeds on correct PIN', () async {
      viewModel.appendDigit('1');
      viewModel.appendDigit('2');
      viewModel.appendDigit('3');
      viewModel.appendDigit('4');

      final future = viewModel.verifyPin();
      expect(viewModel.isLoading, isTrue);

      final result = await future;
      expect(result, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isError, isFalse);
    });

    test('verifyPin transitions loading state and fails on incorrect PIN', () async {
      viewModel.appendDigit('9');
      viewModel.appendDigit('9');
      viewModel.appendDigit('9');
      viewModel.appendDigit('9');

      final future = viewModel.verifyPin();
      expect(viewModel.isLoading, isTrue);

      final result = await future;
      expect(result, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isError, isTrue);
      expect(viewModel.errorMessage, contains('Incorrect PIN'));
      expect(viewModel.enteredPin, isEmpty);
    });

    test('Multiple concurrent verifyPin calls are ignored while loading', () async {
      viewModel.appendDigit('1');
      viewModel.appendDigit('2');
      viewModel.appendDigit('3');
      viewModel.appendDigit('4');

      final firstCall = viewModel.verifyPin();
      expect(viewModel.isLoading, isTrue);

      // Second attempt while loading
      final secondCall = viewModel.verifyPin();
      expect(await secondCall, isFalse);

      final firstResult = await firstCall;
      expect(firstResult, isTrue);
      expect(viewModel.isLoading, isFalse);
    });

    test('authenticateWithBiometrics handles loading and success', () async {
      mockAuth.authResult = true;

      final future = viewModel.authenticateWithBiometrics();
      expect(viewModel.isLoading, isTrue);

      final result = await future;
      expect(result, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isError, isFalse);
    });

    test('authenticateWithBiometrics handles failure gracefully', () async {
      mockAuth.authResult = false;

      final future = viewModel.authenticateWithBiometrics();
      expect(viewModel.isLoading, isTrue);

      final result = await future;
      expect(result, isFalse);
      expect(viewModel.isLoading, isFalse);
    });
  });
}
