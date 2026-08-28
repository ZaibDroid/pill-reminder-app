import '../../app/locator.dart';
import '../../core/domain/adherence_calculator.dart';
import '../../core/domain/dose_scheduler.dart';
import '../../core/domain/timeline_builder.dart';
import '../../core/enums/medicine_status.dart';
import '../../core/enums/time_slot.dart';
import '../../core/enums/view_state.dart';
import '../../core/models/dose_log.dart';
import '../../core/models/medicine.dart';
import '../../core/models/timeline_dose_item.dart';
import '../../core/repositories/dose_log_repository.dart';
import '../../core/repositories/medicine_repository.dart';
import '../../core/utils/custom_logger.dart';
import '../../core/view_model/base_view_model.dart';

// Re-export models and domain helpers for clean consumption
export '../../core/domain/adherence_calculator.dart';
export '../../core/domain/dose_scheduler.dart';
export '../../core/domain/timeline_builder.dart';
export '../../core/enums/time_slot.dart';
export '../../core/models/timeline_dose_item.dart';

/// ViewModel for the MediAlert Home / Dashboard screen adhering to Clean MVVM.
/// Orchestrates data loading, state management, and quick user actions while delegating
/// domain calculations to [DoseScheduler], [TimelineBuilder], and [AdherenceCalculator].
class HomeViewModel extends BaseViewModel {
  final log = CustomLogger(className: '@HomeViewModel');

  final MedicineRepository _medicineRepository;
  final DoseLogRepository _doseLogRepository;
  final DoseScheduler _doseScheduler;
  final TimelineBuilder _timelineBuilder;
  final AdherenceCalculator _adherenceCalculator;

  DateTime _selectedDate = DateTime.now();
  List<Medicine> _activeMedicines = [];
  List<DoseLog> _todayDoseLogs = [];
  List<TimelineDoseItem> _timelineItems = [];
  String? _errorMessage;

  HomeViewModel({
    MedicineRepository? medicineRepository,
    DoseLogRepository? doseLogRepository,
    DoseScheduler? doseScheduler,
    TimelineBuilder? timelineBuilder,
    AdherenceCalculator? adherenceCalculator,
  })  : _medicineRepository = medicineRepository ?? locator<MedicineRepository>(),
        _doseLogRepository = doseLogRepository ?? locator<DoseLogRepository>(),
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

  // --- UI State Getters ---

  DateTime get selectedDate => _selectedDate;
  List<Medicine> get activeMedicines => List.unmodifiable(_activeMedicines);
  List<DoseLog> get todayDoseLogs => List.unmodifiable(_todayDoseLogs);
  List<TimelineDoseItem> get timelineItems => List.unmodifiable(_timelineItems);
  String? get errorMessage => _errorMessage;

  bool get isLoading => state == ViewState.busy;
  bool get hasError => state == ViewState.error;
  bool get isEmpty => !isLoading && !hasError && _timelineItems.isEmpty;
  bool get isSuccess => !isLoading && !hasError && _timelineItems.isNotEmpty;

  bool get isToday => _doseScheduler.isSameDay(_selectedDate, DateTime.now());

  // --- Segmented Timeline Groupings (Delegated to TimelineBuilder) ---

  List<TimelineDoseItem> get morningDoses =>
      _timelineBuilder.filterBySlot(_timelineItems, TimeSlot.morning);

  List<TimelineDoseItem> get afternoonDoses =>
      _timelineBuilder.filterBySlot(_timelineItems, TimeSlot.afternoon);

  List<TimelineDoseItem> get eveningDoses =>
      _timelineBuilder.filterBySlot(_timelineItems, TimeSlot.evening);

  List<TimelineDoseItem> get nightDoses =>
      _timelineBuilder.filterBySlot(_timelineItems, TimeSlot.night);

  Map<TimeSlot, List<TimelineDoseItem>> get groupedTimelineItems =>
      _timelineBuilder.groupTimelineBySlot(_timelineItems);

  // --- Adherence & Progress Calculations (Delegated to AdherenceCalculator) ---

  int get totalDosesCount => _timelineItems.length;

  int get takenDosesCount => _adherenceCalculator.countTaken(_timelineItems);

  int get skippedDosesCount => _adherenceCalculator.countSkipped(_timelineItems);

  int get missedDosesCount => _adherenceCalculator.countMissed(_timelineItems);

  int get pendingDosesCount => _adherenceCalculator.countPending(_timelineItems);

  double get adherenceRate => _adherenceCalculator.calculateAdherenceRate(
        total: totalDosesCount,
        taken: takenDosesCount,
        skipped: skippedDosesCount,
      );

  String get adherenceMotivationalMessage =>
      _adherenceCalculator.getMotivationalMessage(
        total: totalDosesCount,
        taken: takenDosesCount,
        skipped: skippedDosesCount,
        missed: missedDosesCount,
        pending: pendingDosesCount,
        adherenceRate: adherenceRate,
      );

  AdherenceSummary get adherenceSummary =>
      _adherenceCalculator.calculateSummary(_timelineItems);

  // --- Public Orchestration Methods ---

  /// Loads active medications, dose logs, and constructs the timeline for [date].
  Future<void> loadTodayTimeline({DateTime? date}) async {
    _selectedDate = date ?? _selectedDate;
    _errorMessage = null;
    setState(ViewState.busy);
    log.d('@loadTodayTimeline: Fetching data for date $_selectedDate');

    try {
      final allMedicines = await _medicineRepository.getAllMedicines();
      _activeMedicines = _doseScheduler.filterActiveMedicines(allMedicines, _selectedDate);

      // Ensure reminders are loaded for active medicines
      for (final med in _activeMedicines) {
        await med.reminders.load();
      }

      final startOfDay = _doseScheduler.getStartOfDay(_selectedDate);
      final endOfDay = _doseScheduler.getEndOfDay(_selectedDate);

      _todayDoseLogs = await _doseLogRepository.getDoseLogsForDateRange(startOfDay, endOfDay);

      // Ensure relationships are loaded for dose logs
      for (final logItem in _todayDoseLogs) {
        await logItem.medicine.load();
        await logItem.reminderTime.load();
      }

      _timelineItems = _timelineBuilder.buildTimeline(
        activeMedicines: _activeMedicines,
        doseLogs: _todayDoseLogs,
        date: _selectedDate,
      );

      log.i('@loadTodayTimeline: Loaded ${_timelineItems.length} doses for $_selectedDate');
      setState(ViewState.idle);
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      log.e('@loadTodayTimeline: Failed to load timeline data', e, stackTrace);
      setState(ViewState.error);
    }
  }

  /// Refreshes timeline data for the currently selected date.
  Future<void> refresh() async {
    log.d('@refresh: Refreshing timeline');
    await loadTodayTimeline(date: _selectedDate);
  }

  /// Updates the selected date and reloads the schedule.
  Future<void> selectDate(DateTime date) async {
    log.d('@selectDate: Selecting date $date');
    await loadTodayTimeline(date: date);
  }

  /// Marks a timeline dose item as taken and decrements inventory if available.
  Future<void> markAsTaken(TimelineDoseItem item, {DateTime? actualTakenDateTime}) async {
    try {
      log.d('@markAsTaken: Marking dose for "${item.medicine.name}" as taken');
      final takenTime = actualTakenDateTime ?? DateTime.now();

      final logToSave = _prepareDoseLog(
        item: item,
        status: MedicineStatus.taken,
        actualTakenDateTime: takenTime,
      );

      if (logToSave.id != 0 && item.doseLog != null) {
        await _doseLogRepository.updateDoseLog(logToSave);
      } else {
        final id = await _doseLogRepository.saveDoseLog(logToSave);
        logToSave.id = id;
      }

      if (item.medicine.currentStock > 0) {
        item.medicine.currentStock -= 1;
        await _medicineRepository.updateMedicine(item.medicine);
      }

      _updateLocalTimeline(item, updatedStatus: MedicineStatus.taken, updatedLog: logToSave);
      notifyListeners();
    } catch (e, stackTrace) {
      log.e('@markAsTaken: Error marking dose as taken', e, stackTrace);
      rethrow;
    }
  }

  /// Skips a timeline dose item with an optional reason and notes.
  Future<void> skipDose(TimelineDoseItem item, {String? reason, String? notes}) async {
    try {
      log.d('@skipDose: Skipping dose for "${item.medicine.name}" (reason: $reason)');

      final logToSave = _prepareDoseLog(
        item: item,
        status: MedicineStatus.skipped,
        skipReason: reason,
        notes: notes,
      );

      if (logToSave.id != 0 && item.doseLog != null) {
        await _doseLogRepository.updateDoseLog(logToSave);
      } else {
        final id = await _doseLogRepository.saveDoseLog(logToSave);
        logToSave.id = id;
      }

      _updateLocalTimeline(item, updatedStatus: MedicineStatus.skipped, updatedLog: logToSave);
      notifyListeners();
    } catch (e, stackTrace) {
      log.e('@skipDose: Error skipping dose', e, stackTrace);
      rethrow;
    }
  }

  /// Marks a timeline dose item as missed.
  Future<void> markAsMissed(TimelineDoseItem item) async {
    try {
      log.d('@markAsMissed: Marking dose for "${item.medicine.name}" as missed');

      final logToSave = _prepareDoseLog(
        item: item,
        status: MedicineStatus.missed,
      );

      if (logToSave.id != 0 && item.doseLog != null) {
        await _doseLogRepository.updateDoseLog(logToSave);
      } else {
        final id = await _doseLogRepository.saveDoseLog(logToSave);
        logToSave.id = id;
      }

      _updateLocalTimeline(item, updatedStatus: MedicineStatus.missed, updatedLog: logToSave);
      notifyListeners();
    } catch (e, stackTrace) {
      log.e('@markAsMissed: Error marking dose as missed', e, stackTrace);
      rethrow;
    }
  }

  // --- Private Helpers ---

  DoseLog _prepareDoseLog({
    required TimelineDoseItem item,
    required MedicineStatus status,
    DateTime? actualTakenDateTime,
    String? skipReason,
    String? notes,
  }) {
    if (item.doseLog != null) {
      return item.doseLog!
        ..status = status
        ..actualTakenDateTime = actualTakenDateTime ?? item.doseLog!.actualTakenDateTime
        ..skipReason = skipReason ?? item.doseLog!.skipReason
        ..notes = notes ?? item.doseLog!.notes;
    }

    final newLog = DoseLog()
      ..scheduledDateTime = item.scheduledTime
      ..actualTakenDateTime = actualTakenDateTime
      ..status = status
      ..skipReason = skipReason
      ..notes = notes;

    newLog.medicine.value = item.medicine;
    if (item.reminderTime != null) {
      newLog.reminderTime.value = item.reminderTime;
    }
    return newLog;
  }

  void _updateLocalTimeline(
    TimelineDoseItem item, {
    required MedicineStatus updatedStatus,
    required DoseLog updatedLog,
  }) {
    _timelineItems = _timelineBuilder.updateItemInTimeline(
      _timelineItems,
      item,
      updatedStatus: updatedStatus,
      updatedLog: updatedLog,
    );

    final logIndex = _todayDoseLogs.indexWhere((l) => l.id == updatedLog.id);
    if (logIndex != -1) {
      _todayDoseLogs[logIndex] = updatedLog;
    } else {
      _todayDoseLogs.add(updatedLog);
    }
  }
}
