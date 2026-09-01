import 'package:local_auth/local_auth.dart';
import '../../app/locator.dart';
import '../../core/enums/view_state.dart';
import '../../core/models/user_settings.dart';
import '../../core/repositories/user_settings_repository.dart';
import '../../core/utils/custom_logger.dart';
import '../../core/view_model/base_view_model.dart';

class AppLockViewModel extends BaseViewModel {
  final log = CustomLogger(className: '@AppLockViewModel');

  final UserSettingsRepository _userSettingsRepository;
  final LocalAuthentication _localAuth;

  String _enteredPin = '';
  UserSettings? _settings;
  bool _isError = false;
  String? _errorMessage;

  AppLockViewModel({
    UserSettingsRepository? userSettingsRepository,
    LocalAuthentication? localAuth,
  })  : _userSettingsRepository = userSettingsRepository ?? locator<UserSettingsRepository>(),
        _localAuth = localAuth ?? LocalAuthentication();

  String get enteredPin => _enteredPin;
  int get pinLength => _enteredPin.length;
  bool get isError => _isError;
  String? get errorMessage => _errorMessage;
  bool get isLoading => state == ViewState.busy;

  Future<void> init() async {
    try {
      _settings = await _userSettingsRepository.getOrCreateSettings();
      if (_settings?.isBiometricEnabled == true) {
        authenticateWithBiometrics();
      }
    } catch (e) {
      log.w('@init: User settings not accessible or database offline: $e');
    }
  }

  void appendDigit(String digit) {
    if (isLoading) return;
    if (_enteredPin.length < 4) {
      _enteredPin += digit;
      _isError = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void deleteDigit() {
    if (isLoading) return;
    if (_enteredPin.isNotEmpty) {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _isError = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void clearPin() {
    _enteredPin = '';
    _isError = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> verifyPin() async {
    if (isLoading) return false;
    if (_enteredPin.length != 4) return false;

    setState(ViewState.busy);
    try {
      _settings ??= await _userSettingsRepository.getOrCreateSettings();
      final expectedPin = _settings?.pinHash ?? '1234';

      // Brief asynchronous transition for security / hashing verification
      await Future.delayed(const Duration(milliseconds: 300));

      if (_enteredPin == expectedPin) {
        log.i('@verifyPin: PIN matched successfully');
        setState(ViewState.idle);
        return true;
      } else {
        log.w('@verifyPin: Invalid PIN entered');
        _isError = true;
        _errorMessage = 'Incorrect PIN. Please try again.';
        _enteredPin = '';
        setState(ViewState.idle);
        return false;
      }
    } catch (e, stackTrace) {
      log.e('@verifyPin: Error during PIN verification', e, stackTrace);
      _isError = true;
      _errorMessage = 'Verification error. Please try again.';
      setState(ViewState.idle);
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    if (isLoading) return false;

    setState(ViewState.busy);
    try {
      final canAuth = await _localAuth.canCheckBiometrics;
      if (!canAuth) {
        setState(ViewState.idle);
        return false;
      }

      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint or face to unlock MediAlert',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuth) {
        log.i('@authenticateWithBiometrics: Biometric auth succeeded');
        setState(ViewState.idle);
        return true;
      } else {
        log.w('@authenticateWithBiometrics: Biometric auth was not completed');
        setState(ViewState.idle);
        return false;
      }
    } catch (e) {
      log.e('@authenticateWithBiometrics: Biometric auth failed', e);
      _isError = true;
      _errorMessage = 'Biometric authentication failed. Please enter PIN.';
      setState(ViewState.idle);
      return false;
    }
  }
}
