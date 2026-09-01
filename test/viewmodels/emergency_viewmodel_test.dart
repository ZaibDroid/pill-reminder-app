import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:pill_reminder_app/core/repositories/emergency_contact_repository.dart';
import 'package:pill_reminder_app/core/repositories/user_settings_repository.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/ui/viewmodels/emergency_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late DatabaseService databaseService;
  late EmergencyContactRepository emergencyContactRepository;
  late UserSettingsRepository userSettingsRepository;

  setUpAll(() async {
    HttpOverrides.global = null;
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_emerg_vm_test_');
    databaseService = DatabaseService();
    await databaseService.init(
      directory: tempDir.path,
      name: 'test_db_${DateTime.now().microsecondsSinceEpoch}',
      inspector: false,
    );
    emergencyContactRepository = EmergencyContactRepository(databaseService: databaseService);
    userSettingsRepository = UserSettingsRepository(databaseService: databaseService);
  });

  tearDown(() async {
    await databaseService.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });

  group('EmergencyViewModel Unit Tests', () {
    test('Initial loading with empty database sets isEmpty to true', () async {
      final vm = EmergencyViewModel(
        emergencyContactRepository: emergencyContactRepository,
        userSettingsRepository: userSettingsRepository,
      );

      await vm.loadContacts();

      expect(vm.isLoading, isFalse);
      expect(vm.hasError, isFalse);
      expect(vm.isEmpty, isTrue);
      expect(vm.contacts, isEmpty);
      expect(vm.primaryContact, isNull);
      expect(vm.secondaryContacts, isEmpty);
    });

    test('Adding contact validates inputs and persists to Isar', () async {
      final vm = EmergencyViewModel(
        emergencyContactRepository: emergencyContactRepository,
        userSettingsRepository: userSettingsRepository,
      );

      await vm.addContact(
        fullName: 'Dr. Sarah Mitchell',
        phoneNumber: '+1 555 123 4567',
        relationship: 'Cardiologist',
        email: 'dr.sarah@hospital.com',
        isPrimary: true,
      );

      expect(vm.contacts.length, equals(1));
      expect(vm.isEmpty, isFalse);
      expect(vm.primaryContact, isNotNull);
      expect(vm.primaryContact!.fullName, equals('Dr. Sarah Mitchell'));
      expect(vm.primaryContact!.phoneNumber, equals('+1 555 123 4567'));
      expect(vm.primaryContact!.relationship, equals('Cardiologist'));
      expect(vm.primaryContact!.email, equals('dr.sarah@hospital.com'));
      expect(vm.primaryContact!.isPrimary, isTrue);
    });

    test('Input validation throws ArgumentError for empty name or phone', () async {
      final vm = EmergencyViewModel(
        emergencyContactRepository: emergencyContactRepository,
        userSettingsRepository: userSettingsRepository,
      );

      expect(
        () => vm.addContact(fullName: '   ', phoneNumber: '1234567890'),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => vm.addContact(fullName: 'Valid Name', phoneNumber: '   '),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => vm.addContact(fullName: 'Valid Name', phoneNumber: '12'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Editing contact updates entity in database', () async {
      final vm = EmergencyViewModel(
        emergencyContactRepository: emergencyContactRepository,
        userSettingsRepository: userSettingsRepository,
      );

      await vm.addContact(
        fullName: 'Jane Doe',
        phoneNumber: '555-111-2222',
        relationship: 'Daughter',
      );

      final contact = vm.contacts.first;
      contact.fullName = 'Jane Smith';
      contact.relationship = 'Spouse';

      await vm.updateContact(contact);

      expect(vm.contacts.first.fullName, equals('Jane Smith'));
      expect(vm.contacts.first.relationship, equals('Spouse'));
    });

    test('Deleting contact removes it from repository and state', () async {
      final vm = EmergencyViewModel(
        emergencyContactRepository: emergencyContactRepository,
        userSettingsRepository: userSettingsRepository,
      );

      await vm.addContact(
        fullName: 'Contact To Delete',
        phoneNumber: '555-000-0000',
      );

      expect(vm.contacts.length, equals(1));
      final contactId = vm.contacts.first.id;

      await vm.deleteContact(contactId);

      expect(vm.contacts, isEmpty);
      expect(vm.isEmpty, isTrue);
    });

    test('Setting primary contact automatically unsets previous primary contact', () async {
      final vm = EmergencyViewModel(
        emergencyContactRepository: emergencyContactRepository,
        userSettingsRepository: userSettingsRepository,
      );

      await vm.addContact(
        fullName: 'Contact A',
        phoneNumber: '555-111-1111',
        isPrimary: true,
      );

      await vm.addContact(
        fullName: 'Contact B',
        phoneNumber: '555-222-2222',
        isPrimary: false,
      );

      expect(vm.primaryContact!.fullName, equals('Contact A'));
      expect(vm.secondaryContacts.length, equals(1));

      final contactB = vm.contacts.firstWhere((c) => c.fullName == 'Contact B');
      await vm.setPrimaryContact(contactB.id);

      expect(vm.primaryContact!.fullName, equals('Contact B'));
      expect(vm.secondaryContacts.first.fullName, equals('Contact A'));

      await vm.unsetPrimaryContact(contactB.id);
      expect(vm.primaryContact, isNull);
    });

    test('Toggling lock screen setting updates UserSettings', () async {
      final vm = EmergencyViewModel(
        emergencyContactRepository: emergencyContactRepository,
        userSettingsRepository: userSettingsRepository,
      );

      await vm.loadContacts();
      await vm.toggleShowOnLockScreen(true);
      expect(vm.showOnLockScreen, isTrue);

      final settings = await userSettingsRepository.getOrCreateSettings();
      expect(settings.isBiometricEnabled, isTrue);
    });

    test('Handles database failure gracefully and sets hasError state', () async {
      await databaseService.close(deleteFromDisk: true);

      final vm = EmergencyViewModel(
        emergencyContactRepository: emergencyContactRepository,
        userSettingsRepository: userSettingsRepository,
      );

      await vm.loadContacts();

      expect(vm.hasError, isTrue);
      expect(vm.errorMessage, isNotNull);
      expect(vm.isLoading, isFalse);
    });
  });
}
