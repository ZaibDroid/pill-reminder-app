import 'package:isar/isar.dart';

part 'user_settings.g.dart';

@collection
class UserSettings {
  Id id = Isar.autoIncrement;

  bool isBiometricEnabled = false;

  String? pinHash;

  String themeMode = 'system';

  int snoozeDurationMinutes = 10;

  int gracePeriodMinutes = 30;

  String soundName = 'default';

  bool vibrationEnabled = true;

  bool isFirstTimeUser = true;

  DateTime updatedAt = DateTime.now();
}
