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
      return null;
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
      log.i('@loadContacts: Loaded ${_contacts.length} emergency contacts from database');
      setState(ViewState.idle);
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      log.e('@loadContacts: Failed to load emergency contacts', e, stackTrace);
      setState(ViewState.error);
    }
  }

  Future<void> refresh() => loadContacts();

  Future<void> toggleShowOnLockScreen(bool value) async {
    _showOnLockScreen = value;
    notifyListeners();
    try {
      final settings = await _userSettingsRepository.getOrCreateSettings();
      settings.isBiometricEnabled = value;
      await _userSettingsRepository.saveUserSettings(settings);
      log.i('@toggleShowOnLockScreen: Updated lock screen emergency toggle to $value');
    } catch (e, stackTrace) {
      log.e('@toggleShowOnLockScreen: Error persisting lock screen setting', e, stackTrace);
    }
  }

  void validateContactInput(String fullName, String phoneNumber) {
    if (fullName.trim().isEmpty) {
      throw ArgumentError('Contact full name cannot be empty.');
    }
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (phoneNumber.trim().isEmpty || digits.length < 3) {
      throw ArgumentError('A valid phone number is required.');
    }
  }

  Future<void> addContact({
    required String fullName,
    required String phoneNumber,
    String? relationship,
    String? email,
    bool isPrimary = false,
  }) async {
    validateContactInput(fullName, phoneNumber);
    try {
      final contact = EmergencyContact()
        ..fullName = fullName.trim()
        ..phoneNumber = phoneNumber.trim()
        ..relationship = relationship?.trim().isEmpty == true ? null : relationship?.trim()
        ..email = email?.trim().isEmpty == true ? null : email?.trim()
        ..isPrimary = isPrimary;

      await _emergencyContactRepository.saveEmergencyContact(contact);
      log.i('@addContact: Added new emergency contact "${contact.fullName}"');
      await loadContacts();
    } catch (e, stackTrace) {
      log.e('@addContact: Error adding contact', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateContact(EmergencyContact contact) async {
    validateContactInput(contact.fullName, contact.phoneNumber);
    try {
      contact.fullName = contact.fullName.trim();
      contact.phoneNumber = contact.phoneNumber.trim();
      contact.relationship = contact.relationship?.trim().isEmpty == true ? null : contact.relationship?.trim();
      contact.email = contact.email?.trim().isEmpty == true ? null : contact.email?.trim();

      await _emergencyContactRepository.updateEmergencyContact(contact);
      log.i('@updateContact: Updated emergency contact "${contact.fullName}" (id: ${contact.id})');
      await loadContacts();
    } catch (e, stackTrace) {
      log.e('@updateContact: Error updating contact', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteContact(int contactId) async {
    try {
      await _emergencyContactRepository.deleteEmergencyContact(contactId);
      log.i('@deleteContact: Deleted emergency contact with id: $contactId');
      _contacts.removeWhere((c) => c.id == contactId);
      notifyListeners();
    } catch (e, stackTrace) {
      log.e('@deleteContact: Error deleting contact', e, stackTrace);
      rethrow;
    }
  }

  Future<void> setPrimaryContact(int contactId) async {
    try {
      final contact = _contacts.firstWhere((c) => c.id == contactId);
      contact.isPrimary = true;
      await _emergencyContactRepository.updateEmergencyContact(contact);
      log.i('@setPrimaryContact: Set "${contact.fullName}" as primary emergency contact');
      await loadContacts();
    } catch (e, stackTrace) {
      log.e('@setPrimaryContact: Error setting primary contact', e, stackTrace);
      rethrow;
    }
  }

  Future<void> unsetPrimaryContact(int contactId) async {
    try {
      final contact = _contacts.firstWhere((c) => c.id == contactId);
      contact.isPrimary = false;
      await _emergencyContactRepository.updateEmergencyContact(contact);
      log.i('@unsetPrimaryContact: Unset primary status for "${contact.fullName}"');
      await loadContacts();
    } catch (e, stackTrace) {
      log.e('@unsetPrimaryContact: Error unsetting primary contact', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      if (await canLaunchUrl(uri)) {
        log.i('@makePhoneCall: Launching phone dialer for $cleanNumber');
        return await launchUrl(uri);
      } else {
        log.w('@makePhoneCall: Could not launch $uri');
        return false;
      }
    } catch (e, stackTrace) {
      log.e('@makePhoneCall: Error launching phone call for $cleanNumber', e, stackTrace);
      return false;
    }
  }

  Future<bool> sendEmergencySms(String phoneNumber, {String? message}) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = message != null && message.isNotEmpty
        ? Uri(scheme: 'sms', path: cleanNumber, queryParameters: {'body': message})
        : Uri(scheme: 'sms', path: cleanNumber);
    try {
      if (await canLaunchUrl(uri)) {
        log.i('@sendEmergencySms: Launching SMS app for $cleanNumber');
        return await launchUrl(uri);
      } else {
        log.w('@sendEmergencySms: Could not launch SMS for $uri');
        return false;
      }
    } catch (e, stackTrace) {
      log.e('@sendEmergencySms: Error launching SMS for $cleanNumber', e, stackTrace);
      return false;
    }
  }
}
