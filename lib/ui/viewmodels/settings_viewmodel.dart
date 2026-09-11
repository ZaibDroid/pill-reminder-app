import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../app/locator.dart';
import '../../core/enums/view_state.dart';
import '../../core/models/user_settings.dart';
import '../../core/repositories/emergency_contact_repository.dart';
import '../../core/repositories/medicine_repository.dart';
import '../../core/repositories/user_settings_repository.dart';
import '../../core/services/alarm_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/utils/custom_logger.dart';
import '../../core/view_model/base_view_model.dart';

class SettingsViewModel extends BaseViewModel {
  final log = CustomLogger(className: '@SettingsViewModel');

  final UserSettingsRepository _userSettingsRepository;
  final LocalStorageService _localStorageService;
  final MedicineRepository _medicineRepository;
  final EmergencyContactRepository _emergencyContactRepository;
  final AlarmService _alarmService;
  final ThemeService? _themeService;
  final ImagePicker _imagePicker;

  UserSettings? _settings;
  String _userName = 'Eleanor Vance';
  String _patientId = '#MA-9482';
  String? _profileImagePath;
  String? _errorMessage;
  bool _isExporting = false;

  SettingsViewModel({
    UserSettingsRepository? userSettingsRepository,
    LocalStorageService? localStorageService,
    MedicineRepository? medicineRepository,
    EmergencyContactRepository? emergencyContactRepository,
    AlarmService? alarmService,
    ThemeService? themeService,
    ImagePicker? imagePicker,
  })  : _userSettingsRepository = userSettingsRepository ?? locator<UserSettingsRepository>(),
        _localStorageService = localStorageService ?? locator<LocalStorageService>(),
        _medicineRepository = medicineRepository ?? locator<MedicineRepository>(),
        _emergencyContactRepository = emergencyContactRepository ?? locator<EmergencyContactRepository>(),
        _alarmService = alarmService ?? locator<AlarmService>(),
        _themeService = themeService ?? (locator.isRegistered<ThemeService>() ? locator<ThemeService>() : null),
        _imagePicker = imagePicker ?? ImagePicker();

  UserSettings? get settings => _settings;
  String get userName => _userName;
  String get patientId => _patientId;
  String? get profileImagePath => _profileImagePath;
  String? get errorMessage => _errorMessage;
  bool get isExporting => _isExporting;

  bool get isLoading => state == ViewState.busy;
  bool get hasError => state == ViewState.error;

  bool get isHighPriorityAlarmEnabled => _settings?.vibrationEnabled ?? true;
  String get notificationSound => _settings?.soundName ?? 'Clinical Chime';
  String get alarmSound => notificationSound;
  String get themeMode => _settings?.themeMode ?? 'system';
  bool get isPinLockEnabled => _settings?.pinHash != null && _settings!.pinHash!.isNotEmpty;
  bool get isBiometricEnabled => _settings?.isBiometricEnabled ?? false;

  Future<void> loadSettings() async {
    setState(ViewState.busy);
    try {
      _settings = await _userSettingsRepository.getOrCreateSettings();
      _userName = _localStorageService.getString('user_name') ?? 'Eleanor Vance';
      _patientId = _localStorageService.getString('patient_id') ?? '#MA-9482';
      _profileImagePath = _localStorageService.getString('user_profile_image');
      if (_settings?.themeMode != null && _themeService != null) {
        await _themeService.setThemeModeFromString(_settings!.themeMode);
      }
      log.i('@loadSettings: Settings loaded successfully');
      setState(ViewState.idle);
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      log.e('@loadSettings: Failed to load settings', e, stackTrace);
      setState(ViewState.error);
    }
  }

  Future<void> updateProfile({
    required String name,
    required String patientId,
    String? imagePath,
  }) async {
    final trimmedName = name.trim();
    final trimmedId = patientId.trim();

    _userName = trimmedName.isNotEmpty ? trimmedName : 'User';
    _patientId = trimmedId.isNotEmpty ? trimmedId : '#MA-9482';
    _profileImagePath = imagePath;

    await _localStorageService.setString('user_name', _userName);
    await _localStorageService.setString('patient_id', _patientId);
    if (imagePath != null && imagePath.isNotEmpty) {
      await _localStorageService.setString('user_profile_image', imagePath);
    } else {
      await _localStorageService.remove('user_profile_image');
      _profileImagePath = null;
    }
    notifyListeners();
    log.i('@updateProfile: Profile updated to name: $_userName, id: $_patientId, image: $_profileImagePath');
  }

  Future<String?> pickProfileImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        final savedPath = await _saveProfileImageLocally(File(image.path));
        return savedPath;
      }
    } catch (e, stackTrace) {
      log.e('@pickProfileImage: Failed to pick image', e, stackTrace);
    }
    return null;
  }

  Future<String?> takeProfilePhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (photo != null) {
        final savedPath = await _saveProfileImageLocally(File(photo.path));
        return savedPath;
      }
    } catch (e, stackTrace) {
      log.e('@takeProfilePhoto: Failed to take photo', e, stackTrace);
    }
    return null;
  }

  Future<String> _saveProfileImageLocally(File sourceFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${appDir.path}/profile_pictures');
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetFile = File('${profileDir.path}/$fileName');
      await sourceFile.copy(targetFile.path);
      return targetFile.path;
    } catch (e) {
      log.w('@_saveProfileImageLocally: Could not copy locally ($e), returning source path');
      return sourceFile.path;
    }
  }

  Future<void> removeProfileImage() async {
    _profileImagePath = null;
    await _localStorageService.remove('user_profile_image');
    notifyListeners();
  }

  Future<void> setHighPriorityAlarm(bool value) async {
    if (_settings == null) return;
    _settings!.vibrationEnabled = value;
    notifyListeners();
    await _userSettingsRepository.saveUserSettings(_settings!);
  }

  Future<int> syncAllAlarms() async {
    try {
      final count = await _alarmService.rescheduleAllActiveAlarms();
      log.i('@syncAllAlarms: Rescheduled $count active alarms');
      return count;
    } catch (e, stackTrace) {
      log.e('@syncAllAlarms: Error syncing all alarms', e, stackTrace);
      return 0;
    }
  }

  Future<void> setNotificationSound(String sound) async {
    if (_settings == null) return;
    _settings!.soundName = sound;
    notifyListeners();
    await _userSettingsRepository.saveUserSettings(_settings!);
  }

  Future<void> setAlarmSound(String sound) => setNotificationSound(sound);

  Future<void> setThemeMode(String mode) async {
    if (_settings == null) return;
    _settings!.themeMode = mode;
    notifyListeners();
    await _userSettingsRepository.saveUserSettings(_settings!);
    if (_themeService != null) {
      await _themeService.setThemeModeFromString(mode);
    }
  }

  Future<void> setPin(String? pin) async {
    if (_settings == null) return;
    _settings!.pinHash = pin;
    notifyListeners();
    await _userSettingsRepository.saveUserSettings(_settings!);
  }

  Future<void> setBiometric(bool value) async {
    if (_settings == null) return;
    _settings!.isBiometricEnabled = value;
    notifyListeners();
    await _userSettingsRepository.saveUserSettings(_settings!);
  }

  /// Generates a professional, easy-to-read Clinical Health and Medication PDF report.
  Future<pw.Document> generateHealthSummaryPdf() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('MMMM d, yyyy - hh:mm a').format(now);

    final medicines = await _medicineRepository.getAllMedicines();
    for (final med in medicines) {
      await med.reminders.load();
    }

    final contacts = await _emergencyContactRepository.getAllEmergencyContacts();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Top Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MediAlert Clinical Summary',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Comprehensive Patient Health & Prescription Report',
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Report Date',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      dateStr,
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.teal700),
            pw.SizedBox(height: 12),

            // Patient Card
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PATIENT NAME',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        _userName,
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'MEDICAL / PATIENT ID',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        _patientId,
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ACTIVE MEDICATIONS',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '${medicines.length} Prescriptions',
                        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Active Medications Schedule
            pw.Text(
              'Prescription & Medication Schedule',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 8),
            if (medicines.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'No active medications currently registered.',
                  style: const pw.TextStyle(color: PdfColors.grey600),
                ),
              )
            else
              pw.TableHelper.fromTextArray(
                headers: ['Medication', 'Dosage', 'Frequency', 'Instructions', 'Doctor', 'Stock'],
                data: medicines.map((m) {
                  final dosageStr = '${m.dosageValue.toStringAsFixed(m.dosageValue.truncateToDouble() == m.dosageValue ? 0 : 1)} ${m.dosageUnit}';
                  final mealStr = _formatMealInstruction(m.mealType.name);
                  final doctorStr = m.doctorName != null && m.doctorName!.isNotEmpty ? 'Dr. ${m.doctorName}' : '-';
                  final stockStr = '${m.currentStock} left';

                  return [
                    m.name,
                    dosageStr,
                    m.frequency.name.toUpperCase(),
                    mealStr,
                    doctorStr,
                    stockStr,
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
            pw.SizedBox(height: 20),

            // Emergency Contacts Section
            if (contacts.isNotEmpty) ...[
              pw.Text(
                'Emergency Contacts',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: ['Name', 'Relationship', 'Phone Number', 'Priority'],
                data: contacts.map((c) {
                  return [
                    c.fullName,
                    c.relationship,
                    c.phoneNumber,
                    c.isPrimary ? 'PRIMARY' : 'Secondary',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              ),
              pw.SizedBox(height: 20),
            ],

            // Clinical Notes / Footer
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Notice: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                  pw.Expanded(
                    child: pw.Text(
                      'This medical summary is generated for personal health tracking, clinical consultation, and emergency reference. Please consult with your licensed healthcare practitioner for medical guidance.',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  static String _formatMealInstruction(String name) {
    switch (name.toLowerCase()) {
      case 'beforemeal':
        return 'Before Meal';
      case 'aftermeal':
        return 'After Meal';
      case 'withmeal':
        return 'With Meal/Food';
      case 'norelation':
      default:
        return 'Take with water';
    }
  }

  /// Shares the generated Clinical Health PDF directly via native Share sheet (WhatsApp, Email, etc.).
  Future<void> shareHealthReportPdf() async {
    _isExporting = true;
    notifyListeners();
    try {
      final doc = await generateHealthSummaryPdf();
      final bytes = await doc.save();
      final cleanName = _userName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final dateTag = DateFormat('yyyyMMdd').format(DateTime.now());
      final filename = 'MediAlert_Health_Report_${cleanName}_$dateTag.pdf';

      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
      );
      _isExporting = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isExporting = false;
      _errorMessage = e.toString();
      notifyListeners();
      log.e('@shareHealthReportPdf: Failed to share PDF', e, stackTrace);
      rethrow;
    }
  }

  /// Opens preview, layout, print, or local saving dialog for the Health PDF.
  Future<void> previewOrPrintHealthReportPdf() async {
    _isExporting = true;
    notifyListeners();
    try {
      final doc = await generateHealthSummaryPdf();
      final cleanName = _userName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final dateTag = DateFormat('yyyyMMdd').format(DateTime.now());
      final filename = 'MediAlert_Health_Report_${cleanName}_$dateTag.pdf';

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: filename,
      );
      _isExporting = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isExporting = false;
      _errorMessage = e.toString();
      notifyListeners();
      log.e('@previewOrPrintHealthReportPdf: Failed to preview PDF', e, stackTrace);
      rethrow;
    }
  }

  Future<String> exportDataJson() async {
    try {
      final medicines = await _medicineRepository.getAllMedicines();
      final data = {
        'exportDate': DateTime.now().toIso8601String(),
        'user': {'name': _userName, 'patientId': _patientId},
        'medicines': medicines.map((m) => {
          'name': m.name,
          'dosage': '${m.dosageValue} ${m.dosageUnit}',
          'frequency': m.frequency.name,
          'stock': m.currentStock,
        }).toList(),
      };
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      log.e('@exportDataJson: Failed to export data', e);
      rethrow;
    }
  }
}
