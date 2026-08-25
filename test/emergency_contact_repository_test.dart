import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/core/repositories/emergency_contact_repository.dart';
import 'package:pill_reminder_app/core/models/emergency_contact.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService databaseService;
  late EmergencyContactRepository emergencyContactRepository;
  late Directory tempDir;

  setUpAll(() async {
    HttpOverrides.global = null;
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_contact_test_');
    databaseService = DatabaseService();
    await databaseService.init(
      directory: tempDir.path,
      name: 'test_db_${DateTime.now().microsecondsSinceEpoch}',
      inspector: false,
    );
    emergencyContactRepository = EmergencyContactRepository(databaseService: databaseService);
  });

  tearDown(() async {
    if (databaseService.isOpen) {
      await databaseService.close(deleteFromDisk: true);
    }
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('EmergencyContactRepository CRUD & Primary Contact Tests', () {
    test('saveEmergencyContact persists new contact and returns valid ID', () async {
      final contact = EmergencyContact()
        ..fullName = 'Dr. Sarah Wilson'
        ..relationship = 'Primary Physician'
        ..phoneNumber = '+1-555-0199'
        ..email = 'sarah.wilson@hospital.org'
        ..isPrimary = false;

      final id = await emergencyContactRepository.saveEmergencyContact(contact);

      expect(id, isPositive);
      expect(contact.id, equals(id));

      final retrieved = await emergencyContactRepository.getEmergencyContact(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.fullName, equals('Dr. Sarah Wilson'));
      expect(retrieved.phoneNumber, equals('+1-555-0199'));
    });

    test('getAllEmergencyContacts fetches all contacts', () async {
      final c1 = EmergencyContact()..fullName = 'Jane Doe'..phoneNumber = '123';
      final c2 = EmergencyContact()..fullName = 'John Smith'..phoneNumber = '456';

      await emergencyContactRepository.saveEmergencyContact(c1);
      await emergencyContactRepository.saveEmergencyContact(c2);

      final allContacts = await emergencyContactRepository.getAllEmergencyContacts();
      expect(allContacts.length, equals(2));
      expect(allContacts.map((c) => c.fullName), containsAll(['Jane Doe', 'John Smith']));
    });

    test('updateEmergencyContact updates contact fields correctly', () async {
      final contact = EmergencyContact()
        ..fullName = 'Michael Green'
        ..relationship = 'Son'
        ..phoneNumber = '555-1234';

      final id = await emergencyContactRepository.saveEmergencyContact(contact);

      contact.phoneNumber = '555-9876';
      contact.relationship = 'Caregiver / Son';

      await emergencyContactRepository.updateEmergencyContact(contact);

      final updated = await emergencyContactRepository.getEmergencyContact(id);
      expect(updated, isNotNull);
      expect(updated!.phoneNumber, equals('555-9876'));
      expect(updated.relationship, equals('Caregiver / Son'));
    });

    test('deleteEmergencyContact deletes contact from database', () async {
      final contact = EmergencyContact()
        ..fullName = 'Old Contact'
        ..phoneNumber = '000-0000';

      final id = await emergencyContactRepository.saveEmergencyContact(contact);
      final deleteSuccess = await emergencyContactRepository.deleteEmergencyContact(id);

      expect(deleteSuccess, isTrue);

      final retrieved = await emergencyContactRepository.getEmergencyContact(id);
      expect(retrieved, isNull);

      final allContacts = await emergencyContactRepository.getAllEmergencyContacts();
      expect(allContacts, isEmpty);
    });

    test('getPrimaryContact returns the primary contact and manages exclusive primary state', () async {
      final contact1 = EmergencyContact()
        ..fullName = 'First Primary'
        ..phoneNumber = '111'
        ..isPrimary = true;
      await emergencyContactRepository.saveEmergencyContact(contact1);

      var primary = await emergencyContactRepository.getPrimaryContact();
      expect(primary, isNotNull);
      expect(primary!.fullName, equals('First Primary'));

      // Save new primary contact
      final contact2 = EmergencyContact()
        ..fullName = 'Second Primary'
        ..phoneNumber = '222'
        ..isPrimary = true;
      await emergencyContactRepository.saveEmergencyContact(contact2);

      primary = await emergencyContactRepository.getPrimaryContact();
      expect(primary, isNotNull);
      expect(primary!.fullName, equals('Second Primary'));

      // Check contact1 is no longer primary
      final c1Updated = await emergencyContactRepository.getEmergencyContact(contact1.id);
      expect(c1Updated!.isPrimary, isFalse);
    });
  });
}
