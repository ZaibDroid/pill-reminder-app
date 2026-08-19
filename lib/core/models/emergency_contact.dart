import 'package:isar/isar.dart';

part 'emergency_contact.g.dart';

@collection
class EmergencyContact {
  Id id = Isar.autoIncrement;

  late String fullName;

  String? relationship;

  late String phoneNumber;

  String? email;

  bool isPrimary = false;

  DateTime createdAt = DateTime.now();
}
