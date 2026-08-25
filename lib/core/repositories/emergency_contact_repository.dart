import 'package:isar/isar.dart';
import '../../app/locator.dart';
import '../models/emergency_contact.dart';
import '../services/database_service.dart';
import '../utils/custom_logger.dart';

class EmergencyContactRepository {
  final log = CustomLogger(className: '@EmergencyContactRepository');
  final DatabaseService _databaseService;

  EmergencyContactRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? locator<DatabaseService>();

  Isar get _isar => _databaseService.isar;

  /// Creates and saves a new [EmergencyContact] entity.
  /// If [contact.isPrimary] is true, unsets previous primary contacts within the transaction.
  Future<Id> saveEmergencyContact(EmergencyContact contact) async {
    try {
      log.d('@saveEmergencyContact: Saving emergency contact "${contact.fullName}"');
      return await _isar.writeTxn(() async {
        if (contact.isPrimary) {
          final previousPrimaries = await _isar.emergencyContacts
              .filter()
              .isPrimaryEqualTo(true)
              .findAll();
          for (final prev in previousPrimaries) {
            if (prev.id != contact.id) {
              prev.isPrimary = false;
              await _isar.emergencyContacts.put(prev);
            }
          }
        }
        return await _isar.emergencyContacts.put(contact);
      });
    } catch (e, stackTrace) {
      log.e('@saveEmergencyContact: Error saving emergency contact "${contact.fullName}"', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves an [EmergencyContact] entity by its [id].
  Future<EmergencyContact?> getEmergencyContact(Id id) async {
    try {
      log.d('@getEmergencyContact: Fetching emergency contact with id $id');
      return await _isar.emergencyContacts.get(id);
    } catch (e, stackTrace) {
      log.e('@getEmergencyContact: Error getting emergency contact $id', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves all [EmergencyContact] entities from the database.
  Future<List<EmergencyContact>> getAllEmergencyContacts() async {
    try {
      log.d('@getAllEmergencyContacts: Fetching all emergency contacts');
      return await _isar.emergencyContacts.where().findAll();
    } catch (e, stackTrace) {
      log.e('@getAllEmergencyContacts: Error getting all emergency contacts', e, stackTrace);
      rethrow;
    }
  }

  /// Updates an existing [EmergencyContact] entity.
  /// If [contact.isPrimary] is true, unsets other primary contacts.
  Future<Id> updateEmergencyContact(EmergencyContact contact) async {
    try {
      log.d('@updateEmergencyContact: Updating emergency contact with id ${contact.id}');
      return await _isar.writeTxn(() async {
        if (contact.isPrimary) {
          final previousPrimaries = await _isar.emergencyContacts
              .filter()
              .isPrimaryEqualTo(true)
              .findAll();
          for (final prev in previousPrimaries) {
            if (prev.id != contact.id) {
              prev.isPrimary = false;
              await _isar.emergencyContacts.put(prev);
            }
          }
        }
        return await _isar.emergencyContacts.put(contact);
      });
    } catch (e, stackTrace) {
      log.e('@updateEmergencyContact: Error updating emergency contact ${contact.id}', e, stackTrace);
      rethrow;
    }
  }

  /// Deletes an [EmergencyContact] entity by its [id].
  Future<bool> deleteEmergencyContact(Id id) async {
    try {
      log.d('@deleteEmergencyContact: Deleting emergency contact with id $id');
      return await _isar.writeTxn(() async {
        return await _isar.emergencyContacts.delete(id);
      });
    } catch (e, stackTrace) {
      log.e('@deleteEmergencyContact: Error deleting emergency contact $id', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves the primary emergency contact designated by [isPrimary] = true.
  Future<EmergencyContact?> getPrimaryContact() async {
    try {
      log.d('@getPrimaryContact: Fetching primary emergency contact');
      return await _isar.emergencyContacts
          .filter()
          .isPrimaryEqualTo(true)
          .findFirst();
    } catch (e, stackTrace) {
      log.e('@getPrimaryContact: Error getting primary emergency contact', e, stackTrace);
      rethrow;
    }
  }
}
