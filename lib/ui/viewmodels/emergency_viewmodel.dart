import 'package:url_launcher/url_launcher.dart';
import '../../app/locator.dart';
import '../../core/enums/view_state.dart';
import '../../core/models/emergency_contact.dart';
import '../../core/repositories/emergency_contact_repository.dart';
import '../../core/repositories/user_settings_repository.dart';
import '../../core/utils/custom_logger.dart';
import '../../core/view_model/base_view_model.dart';

class EmergencyViewModel extends BaseViewModel {
  final log = CustomLogger(className: '@EmergencyViewModel');

  final EmergencyContactRepository _emergencyContactRepository;
  final UserSettingsRepository _userSettingsRepository;

  List<EmergencyContact> _contacts = [];
  bool _showOnLockScreen = true;
  String? _errorMessage;

  EmergencyViewModel({
    EmergencyContactRepository? emergencyContactRepository,
    UserSettingsRepository? userSettingsRepository,
  })  : _emergencyContactRepository = emergencyContactRepository ?? locator<EmergencyContactRepository>(),
        _userSettingsRepository = userSettingsRepository ?? locator<UserSettingsRepository>();

  List<EmergencyContact> get contacts => List.unmodifiable(_contacts);
  bool get showOnLockScreen => _showOnLockScreen;
  String? get errorMessage => _errorMessage;

  bool get isLoading => state == ViewState.busy;
  bool get hasError => state == ViewState.error;
  bool get isEmpty => !isLoading && !hasError && _contacts.isEmpty;

  EmergencyContact? get primaryContact {
    try {
      return _contacts.firstWhere((c) => c.isPrimary);
    } catch (_) {
      return _contacts.isNotEmpty ? _contacts.first : null;
    }
  }

  List<EmergencyContact> get secondaryContacts =>
      _contacts.where((c) => !c.isPrimary).toList();

  Future<void> loadContacts() async {
    _errorMessage = null;
    setState(ViewState.busy);
    try {
      _contacts = await _emergencyContactRepository.getAllEmergencyContacts();
      final settings = await _userSettingsRepository.getOrCreateSettings();
      _showOnLockScreen = settings.isBiometricEnabled;
      log.i('@loadContacts: Loaded ${_contacts.length} emergency contacts');
      setState(ViewState.idle);
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      log.e('@loadContacts: Failed to load contacts', e, stackTrace);
      setState(ViewState.error);
    }
  }

  Future<void> toggleShowOnLockScreen(bool value) async {
    _showOnLockScreen = value;
    notifyListeners();
    try {
      final settings = await _userSettingsRepository.getOrCreateSettings();
      settings.isBiometricEnabled = value;
      await _userSettingsRepository.saveUserSettings(settings);
    } catch (e) {
      log.e('@toggleShowOnLockScreen: Error persisting setting', e);
    }
  }

  Future<void> addContact({
    required String fullName,
    required String phoneNumber,
    String? relationship,
    String? email,
    bool isPrimary = false,
  }) async {
    try {
      final contact = EmergencyContact()
        ..fullName = fullName.trim()
        ..phoneNumber = phoneNumber.trim()
        ..relationship = relationship?.trim()
        ..email = email?.trim()
        ..isPrimary = isPrimary;

      await _emergencyContactRepository.saveEmergencyContact(contact);
      await loadContacts();
    } catch (e, stackTrace) {
      log.e('@addContact: Error adding contact', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateContact(EmergencyContact contact) async {
    try {
      await _emergencyContactRepository.updateEmergencyContact(contact);
      await loadContacts();
    } catch (e, stackTrace) {
      log.e('@updateContact: Error updating contact', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteContact(int contactId) async {
    try {
      await _emergencyContactRepository.deleteEmergencyContact(contactId);
      _contacts.removeWhere((c) => c.id == contactId);
      notifyListeners();
    } catch (e, stackTrace) {
      log.e('@deleteContact: Error deleting contact', e, stackTrace);
      rethrow;
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        log.w('@makePhoneCall: Could not launch $uri');
      }
    } catch (e) {
      log.e('@makePhoneCall: Error launching phone call', e);
    }
  }
}
