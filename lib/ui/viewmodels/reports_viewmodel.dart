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
import '../../core/models/medicine.dart';
import '../../core/repositories/dose_log_repository.dart';
import '../../core/repositories/medicine_repository.dart';
import '../../core/utils/custom_logger.dart';
import '../../core/view_model/base_view_model.dart';

class ReportsViewModel extends BaseViewModel {
  final log = CustomLogger(className: '@ReportsViewModel');

  final DoseLogRepository _doseLogRepository;
  final MedicineRepository _medicineRepository;
  final DoseScheduler _doseScheduler;
  final TimelineBuilder _timelineBuilder;
  final AdherenceCalculator _adherenceCalculator;

  DateTime _currentMonth = DateTime.now();
  List<DoseLog> _monthLogs = [];
  List<Medicine> _medicines = [];
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
                : const AdherenceCalculator());

  DateTime get currentMonth => _currentMonth;
  List<DoseLog> get monthLogs => List.unmodifiable(_monthLogs);
  List<Medicine> get medicines => List.unmodifiable(_medicines);
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

      for (int day = 1; day <= daysInMonth; day++) {
        final dayDate = DateTime(_currentMonth.year, _currentMonth.month, day);
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

        _dailyDoseCounts[day] = dayTotal;
        if (dayTotal > 0) {
          _dailyAdherenceRates[day] = _adherenceCalculator.calculateAdherenceRate(
            total: dayTotal,
            taken: dayTaken,
            skipped: daySkipped,
          );
        } else {
          _dailyAdherenceRates[day] = 0.0;
        }

        scheduledSum += dayTotal;
        takenSum += dayTaken;
        skippedSum += daySkipped;
        missedSum += dayMissed;
      }

      _totalScheduledCount = scheduledSum > 0 ? scheduledSum : _monthLogs.length;
      _takenCount = takenSum > 0 ? takenSum : _monthLogs.where((l) => l.status == MedicineStatus.taken).length;
      _skippedCount = skippedSum > 0 ? skippedSum : _monthLogs.where((l) => l.status == MedicineStatus.skipped).length;
      _missedCount = missedSum > 0 ? missedSum : _monthLogs.where((l) => l.status == MedicineStatus.missed).length;

      _calculateStreak(daysInMonth);

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

  /// Pure Dart method constructing the PDF Document for reporting & testing.
  pw.Document generatePdfReport() {
    final pdf = pw.Document();
    final monthStr = DateFormat('MMMM yyyy').format(_currentMonth);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'MediAlert Health Report',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.Text(
                    monthStr,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Adherence Highlights
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPdfStat('Adherence', '${adherenceRate.toStringAsFixed(1)}%'),
                  _buildPdfStat('Taken', '$_takenCount / $_totalScheduledCount'),
                  _buildPdfStat('Skipped', '$_skippedCount'),
                  _buildPdfStat('Missed', '$_missedCount'),
                  _buildPdfStat('Longest Streak', '$_longestStreakDays Days'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Dose Distribution Breakdown
            pw.Text(
              'Dose Distribution Summary',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Bullet(text: 'Taken Doses: $_takenCount (${takenPercentage.toStringAsFixed(1)}%)'),
            pw.Bullet(text: 'Skipped Doses: $_skippedCount (${skippedPercentage.toStringAsFixed(1)}%)'),
            pw.Bullet(text: 'Missed Doses: $_missedCount (${missedPercentage.toStringAsFixed(1)}%)'),
            pw.SizedBox(height: 20),

            // Active Medications List
            pw.Text(
              'Active Medications',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (_medicines.isEmpty)
              pw.Text('No medications registered.', style: const pw.TextStyle(color: PdfColors.grey600))
            else
              pw.TableHelper.fromTextArray(
                headers: ['Medication', 'Dosage', 'Frequency', 'Instructions'],
                data: _medicines.map((m) {
                  return [
                    m.name,
                    '${m.dosageValue} ${m.dosageUnit}',
                    m.frequency.name,
                    m.mealType.name,
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
            pw.SizedBox(height: 20),

            // Dose Logs Table
            pw.Text(
              'Recorded Dose Logs ($monthStr)',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (_monthLogs.isEmpty)
              pw.Text('No dose logs recorded for this period.', style: const pw.TextStyle(color: PdfColors.grey600))
            else
              pw.TableHelper.fromTextArray(
                headers: ['Date & Time', 'Medication', 'Status', 'Logged At'],
                data: _monthLogs.map((log) {
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
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              ),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPdfStat(String title, String value) {
    return pw.Column(
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  /// Triggers PDF export preview and print dialog.
  Future<void> exportPdfReport() async {
    _isExporting = true;
    notifyListeners();
    try {
      final doc = generatePdfReport();
      final monthStr = DateFormat('MM_yyyy').format(_currentMonth);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'MediAlert_Report_$monthStr.pdf',
      );
      _isExporting = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isExporting = false;
      _errorMessage = e.toString();
      notifyListeners();
      log.e('@exportPdfReport: Failed to export PDF', e, stackTrace);
      rethrow;
    }
  }
}
