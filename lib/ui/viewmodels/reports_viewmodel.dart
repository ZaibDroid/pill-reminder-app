import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../app/locator.dart';
import '../../core/domain/adherence_calculator.dart';
import '../../core/domain/dose_scheduler.dart';
import '../../core/domain/timeline_builder.dart';
import '../../core/enums/medicine_status.dart';
import '../../core/enums/view_state.dart';
import '../../core/models/dose_log.dart';
import '../../core/models/emergency_contact.dart';
import '../../core/models/medicine.dart';
import '../../core/repositories/dose_log_repository.dart';
import '../../core/repositories/emergency_contact_repository.dart';
import '../../core/repositories/medicine_repository.dart';
import '../../core/repositories/user_settings_repository.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/utils/custom_logger.dart';
import '../../core/view_model/base_view_model.dart';

class ReportsViewModel extends BaseViewModel {
  final log = CustomLogger(className: '@ReportsViewModel');

  final DoseLogRepository _doseLogRepository;
  final MedicineRepository _medicineRepository;
  final DoseScheduler _doseScheduler;
  final TimelineBuilder _timelineBuilder;
  final AdherenceCalculator _adherenceCalculator;
  final EmergencyContactRepository? _emergencyContactRepository;
  final LocalStorageService? _localStorageService;

  DateTime _currentMonth = DateTime.now();
  List<DoseLog> _monthLogs = [];
  List<Medicine> _medicines = [];
  List<EmergencyContact> _contacts = [];
  String _userName = 'Eleanor Vance';
  String _patientId = '#MA-9482';
  final Map<int, double> _dailyAdherenceRates = {};
  final Map<int, int> _dailyDoseCounts = {};

  int _totalScheduledCount = 0;
  int _takenCount = 0;
  int _skippedCount = 0;
  int _missedCount = 0;
  int _longestStreakDays = 0;
  bool _isExporting = false;
  String? _errorMessage;

  ReportsViewModel({
    DoseLogRepository? doseLogRepository,
    MedicineRepository? medicineRepository,
    DoseScheduler? doseScheduler,
    TimelineBuilder? timelineBuilder,
    AdherenceCalculator? adherenceCalculator,
    UserSettingsRepository? userSettingsRepository,
    EmergencyContactRepository? emergencyContactRepository,
    LocalStorageService? localStorageService,
  })  : _doseLogRepository = doseLogRepository ?? locator<DoseLogRepository>(),
        _medicineRepository = medicineRepository ?? locator<MedicineRepository>(),
        _doseScheduler = doseScheduler ??
            (locator.isRegistered<DoseScheduler>()
                ? locator<DoseScheduler>()
                : const DoseScheduler()),
        _timelineBuilder = timelineBuilder ??
            (locator.isRegistered<TimelineBuilder>()
                ? locator<TimelineBuilder>()
                : const TimelineBuilder()),
        _adherenceCalculator = adherenceCalculator ??
            (locator.isRegistered<AdherenceCalculator>()
                ? locator<AdherenceCalculator>()
                : const AdherenceCalculator()),
        _emergencyContactRepository = emergencyContactRepository ??
            (locator.isRegistered<EmergencyContactRepository>()
                ? locator<EmergencyContactRepository>()
                : null),
        _localStorageService = localStorageService ??
            (locator.isRegistered<LocalStorageService>()
                ? locator<LocalStorageService>()
                : null);

  DateTime get currentMonth => _currentMonth;
  List<DoseLog> get monthLogs => List.unmodifiable(_monthLogs);
  List<Medicine> get medicines => List.unmodifiable(_medicines);
  List<EmergencyContact> get contacts => List.unmodifiable(_contacts);
  String get userName => _userName;
  String get patientId => _patientId;
  Map<int, double> get dailyAdherenceRates => Map.unmodifiable(_dailyAdherenceRates);
  Map<int, int> get dailyDoseCounts => Map.unmodifiable(_dailyDoseCounts);

  int get totalScheduledCount => _totalScheduledCount;
  int get takenCount => _takenCount;
  int get skippedCount => _skippedCount;
  int get missedCount => _missedCount;
  int get longestStreakDays => _longestStreakDays;
  bool get isExporting => _isExporting;
  String? get errorMessage => _errorMessage;

  double get takenPercentage =>
      _totalScheduledCount == 0 ? 0.0 : (_takenCount / _totalScheduledCount) * 100.0;
  double get skippedPercentage =>
      _totalScheduledCount == 0 ? 0.0 : (_skippedCount / _totalScheduledCount) * 100.0;
  double get missedPercentage =>
      _totalScheduledCount == 0 ? 0.0 : (_missedCount / _totalScheduledCount) * 100.0;

  double get adherenceRate => _adherenceCalculator.calculateAdherenceRate(
        total: _totalScheduledCount,
        taken: _takenCount,
        skipped: _skippedCount,
      );

  bool get isLoading => state == ViewState.busy;
  bool get hasError => state == ViewState.error;
  bool get isEmpty => !isLoading && !hasError && _totalScheduledCount == 0 && _monthLogs.isEmpty;

  Future<void> loadMonthlyReports({DateTime? month}) async {
    _currentMonth = month ?? _currentMonth;
    _errorMessage = null;
    setState(ViewState.busy);
    try {
      final startOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1, 0, 0, 0, 0);
      final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
      final endOfMonth = DateTime(_currentMonth.year, _currentMonth.month, daysInMonth, 23, 59, 59, 999);

      _medicines = await _medicineRepository.getAllMedicines();
      for (final med in _medicines) {
        await med.reminders.load();
      }

      _monthLogs = await _doseLogRepository.getDoseLogsForDateRange(startOfMonth, endOfMonth);
      for (final l in _monthLogs) {
        await l.medicine.load();
        await l.reminderTime.load();
      }

      _dailyAdherenceRates.clear();
      _dailyDoseCounts.clear();

      int scheduledSum = 0;
      int takenSum = 0;
      int skippedSum = 0;
      int missedSum = 0;

      final now = DateTime.now();
      final isCurrentMonth = _currentMonth.year == now.year && _currentMonth.month == now.month;
      final isFutureMonth = _currentMonth.isAfter(DateTime(now.year, now.month + 1, 0));
      final todayEndOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      for (int day = 1; day <= daysInMonth; day++) {
        final dayDate = DateTime(_currentMonth.year, _currentMonth.month, day);
        final isFutureDay = isFutureMonth || (isCurrentMonth && dayDate.isAfter(todayEndOfDay));
        final dayActive = _doseScheduler.filterActiveMedicines(_medicines, dayDate);
        final dayLogs = _monthLogs
            .where((l) =>
                l.scheduledDateTime.year == dayDate.year &&
                l.scheduledDateTime.month == dayDate.month &&
                l.scheduledDateTime.day == dayDate.day)
            .toList();

        final dayItems = _timelineBuilder.buildTimeline(
          activeMedicines: dayActive,
          doseLogs: dayLogs,
          date: dayDate,
        );

        final dayTotal = dayItems.length;
        final dayTaken = _adherenceCalculator.countTaken(dayItems);
        final daySkipped = _adherenceCalculator.countSkipped(dayItems);
        final dayMissed = _adherenceCalculator.countMissed(dayItems);

        _dailyDoseCounts[day] = isFutureDay ? 0 : dayTotal;
        if (dayTotal > 0 && !isFutureDay) {
          _dailyAdherenceRates[day] = _adherenceCalculator.calculateAdherenceRate(
            total: dayTotal,
            taken: dayTaken,
            skipped: daySkipped,
          );
        } else {
          _dailyAdherenceRates[day] = 0.0;
        }

        if (!isFutureDay) {
          scheduledSum += dayTotal;
          takenSum += dayTaken;
          skippedSum += daySkipped;
          missedSum += dayMissed;
        }
      }

      _totalScheduledCount = scheduledSum > 0 ? scheduledSum : _monthLogs.length;
      _takenCount = takenSum > 0 ? takenSum : _monthLogs.where((l) => l.status == MedicineStatus.taken).length;
      _skippedCount = skippedSum > 0 ? skippedSum : _monthLogs.where((l) => l.status == MedicineStatus.skipped).length;
      _missedCount = missedSum > 0 ? missedSum : _monthLogs.where((l) => l.status == MedicineStatus.missed).length;

      _calculateStreak(daysInMonth);

      if (_localStorageService != null) {
        _userName = _localStorageService.getString('user_name') ?? 'Eleanor Vance';
        _patientId = _localStorageService.getString('patient_id') ?? '#MA-9482';
      }

      if (_emergencyContactRepository != null) {
        _contacts = await _emergencyContactRepository.getAllEmergencyContacts();
      }

      log.i('@loadMonthlyReports: Processed ${_monthLogs.length} logs and $_totalScheduledCount scheduled doses for $_currentMonth');
      setState(ViewState.idle);
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      log.e('@loadMonthlyReports: Error loading monthly report', e, stackTrace);
      setState(ViewState.error);
    }
  }

  void _calculateStreak(int daysInMonth) {
    int maxStreak = 0;
    int currentStreak = 0;
    final now = DateTime.now();

    for (int day = 1; day <= daysInMonth; day++) {
      final dayDate = DateTime(_currentMonth.year, _currentMonth.month, day);
      if (dayDate.isAfter(now)) {
        break;
      }

      final count = _dailyDoseCounts[day] ?? 0;
      final rate = _dailyAdherenceRates[day] ?? 0.0;

      if (count > 0) {
        if (rate >= 100.0) {
          currentStreak++;
          if (currentStreak > maxStreak) {
            maxStreak = currentStreak;
          }
        } else {
          currentStreak = 0;
        }
      }
    }
    _longestStreakDays = maxStreak;
  }

  /// Pure Dart method constructing the comprehensive PDF Document for reporting & testing.
  pw.Document generatePdfReport() {
    final pdf = pw.Document();
    final monthStr = DateFormat('MMMM yyyy').format(_currentMonth);
    final now = DateTime.now();
    final dateStr = DateFormat('MMMM d, yyyy - hh:mm a').format(now);

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
                      'MediAlert Clinical & Health Summary',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Monthly Adherence & Prescription Report - $monthStr',
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
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Divider(thickness: 1, color: PdfColors.teal800),
            pw.SizedBox(height: 12),

            // Patient & Summary Info Card
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.teal50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.teal200),
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
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
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
                        'REPORTING PERIOD',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        monthStr,
                        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
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
                        '${_medicines.length} Prescriptions',
                        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Adherence Highlights
            pw.Text(
              'Monthly Adherence Highlights',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPdfStat('Overall Adherence', '${adherenceRate.toStringAsFixed(1)}%'),
                  _buildPdfStat('Taken Doses', '$_takenCount / $_totalScheduledCount'),
                  _buildPdfStat('Skipped Doses', '$_skippedCount'),
                  _buildPdfStat('Missed Doses', '$_missedCount'),
                  _buildPdfStat('Longest Streak', '$_longestStreakDays Days'),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Dose Distribution Breakdown
            pw.Text(
              'Dose Distribution Summary',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),
            pw.SizedBox(height: 6),
            pw.Bullet(text: 'Taken Doses: $_takenCount (${takenPercentage.toStringAsFixed(1)}%)'),
            pw.Bullet(text: 'Skipped Doses: $_skippedCount (${skippedPercentage.toStringAsFixed(1)}%)'),
            pw.Bullet(text: 'Missed Doses: $_missedCount (${missedPercentage.toStringAsFixed(1)}%)'),
            pw.SizedBox(height: 16),

            // Active Medications List
            pw.Text(
              'Prescription & Medication Schedule',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),
            pw.SizedBox(height: 8),
            if (_medicines.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text('No active medications registered.', style: const pw.TextStyle(color: PdfColors.grey600)),
              )
            else
              pw.TableHelper.fromTextArray(
                headers: ['Medication', 'Dosage', 'Frequency', 'Instructions', 'Doctor', 'Stock'],
                data: _medicines.map((m) {
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
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              ),
            pw.SizedBox(height: 16),

            // Emergency Contacts Section
            if (_contacts.isNotEmpty) ...[
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
                data: _contacts.map((c) {
                  return [
                    c.fullName,
                    c.relationship,
                    c.phoneNumber,
                    c.isPrimary ? 'PRIMARY' : 'Secondary',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              ),
              pw.SizedBox(height: 16),
            ],

            // Dose Logs Table
            pw.Text(
              'Recorded Dose Logs ($monthStr)',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),
            pw.SizedBox(height: 8),
            if (_monthLogs.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text('No dose logs recorded for this period.', style: const pw.TextStyle(color: PdfColors.grey600)),
              )
            else
              pw.TableHelper.fromTextArray(
                headers: ['Scheduled Time', 'Medication', 'Status', 'Logged At'],
                data: _monthLogs.take(50).map((log) {
                  final timeStr = DateFormat('yyyy-MM-dd HH:mm').format(log.scheduledDateTime);
                  final takenStr = log.actualTakenDateTime != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(log.actualTakenDateTime!)
                      : '-';
                  return [
                    timeStr,
                    log.medicine.value?.name ?? 'Medication',
                    log.status.name.toUpperCase(),
                    takenStr,
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              ),
            pw.SizedBox(height: 16),

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

  pw.Widget _buildPdfStat(String title, String value) {
    return pw.Column(
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  /// Shares the generated Clinical Health PDF directly via native Share sheet (WhatsApp, Email, etc.).
  Future<void> shareHealthReportPdf() async {
    _isExporting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final doc = generatePdfReport();
      final bytes = await doc.save();
      final cleanName = _userName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final monthTag = DateFormat('yyyyMM').format(_currentMonth);
      final filename = 'MediAlert_Health_Report_${cleanName}_$monthTag.pdf';

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
    _errorMessage = null;
    notifyListeners();
    try {
      final doc = generatePdfReport();
      final cleanName = _userName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final monthTag = DateFormat('yyyyMM').format(_currentMonth);
      final filename = 'MediAlert_Health_Report_${cleanName}_$monthTag.pdf';

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

  /// Triggers PDF export preview and print dialog (backwards compatible).
  Future<void> exportPdfReport() async {
    return previewOrPrintHealthReportPdf();
  }
}
