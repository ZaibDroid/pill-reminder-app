import 'package:flutter/material.dart';
import 'app/locator.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const PillReminderApp());
}
