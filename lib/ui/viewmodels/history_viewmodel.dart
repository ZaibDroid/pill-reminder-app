import '../../app/locator.dart';
import '../../core/domain/adherence_calculator.dart';
import '../../core/domain/dose_scheduler.dart';
import '../../core/domain/timeline_builder.dart';
import '../../core/enums/view_state.dart';
import '../../core/models/timeline_dose_item.dart';
import '../../core/repositories/dose_log_repository.dart';
import '../../core/repositories/medicine_repository.dart';
import '../../core/utils/custom_logger.dart';
import '../../core/view_model/base_view_model.dart';

class HistoryViewModel extends BaseViewModel {
  final log = CustomLogger(className: '@HistoryViewModel');

  final DoseLogRepository _doseLogRepository;
  final MedicineRepository _medicineRepository;
  final DoseScheduler _doseScheduler;
  final TimelineBuilder _timelineBuilder;
  final AdherenceCalculator _adherenceCalculator;

  DateTime _selectedDate = DateTime.now();
  List<TimelineDoseItem> _items = [];
  String? _errorMessage;

  HistoryViewModel({
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

  DateTime get selectedDate => _selectedDate;
  List<TimelineDoseItem> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;

  bool get isLoading => state == ViewState.busy;
  bool get hasError => state == ViewState.error;
  bool get isEmpty => !isLoading && !hasError && _items.isEmpty;

  int get totalDosesCount => _items.length;
  int get takenDosesCount => _adherenceCalculator.countTaken(_items);
  int get skippedDosesCount => _adherenceCalculator.countSkipped(_items);
  int get missedDosesCount => _adherenceCalculator.countMissed(_items);

  double get adherenceRate => _adherenceCalculator.calculateAdherenceRate(
        total: totalDosesCount,
        taken: takenDosesCount,
        skipped: skippedDosesCount,
      );

  String get motivationalMessage => _adherenceCalculator.getMotivationalMessage(
        total: totalDosesCount,
        taken: takenDosesCount,
        skipped: skippedDosesCount,
        missed: missedDosesCount,
        pending: _adherenceCalculator.countPending(_items),
        adherenceRate: adherenceRate,
      );

  Future<void> loadHistoryForDate(DateTime date) async {
    _selectedDate = date;
    _errorMessage = null;
    setState(ViewState.busy);
    try {
      final allMedicines = await _medicineRepository.getAllMedicines();
      final active = _doseScheduler.filterActiveMedicines(allMedicines, _selectedDate);
      for (final med in active) {
        await med.reminders.load();
      }

      final startOfDay = _doseScheduler.getStartOfDay(_selectedDate);
      final endOfDay = _doseScheduler.getEndOfDay(_selectedDate);
      final logs = await _doseLogRepository.getDoseLogsForDateRange(startOfDay, endOfDay);

      for (final l in logs) {
        await l.medicine.load();
        await l.reminderTime.load();
      }

      _items = _timelineBuilder.buildTimeline(
        activeMedicines: active,
        doseLogs: logs,
        date: _selectedDate,
      );

      log.i('@loadHistoryForDate: Loaded ${_items.length} dose records for $_selectedDate');
      setState(ViewState.idle);
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      log.e('@loadHistoryForDate: Failed to load history', e, stackTrace);
      setState(ViewState.error);
    }
  }

  void selectDate(DateTime date) {
    loadHistoryForDate(date);
  }

  void jumpToToday() {
    loadHistoryForDate(DateTime.now());
  }

  Future<void> refresh() async {
    await loadHistoryForDate(_selectedDate);
  }
}
