import '../../app/locator.dart';
import '../../core/enums/view_state.dart';
import '../../core/models/medicine.dart';
import '../../core/repositories/medicine_repository.dart';
import '../../core/utils/custom_logger.dart';
import '../../core/view_model/base_view_model.dart';

class MedicineViewModel extends BaseViewModel {
  final log = CustomLogger(className: '@MedicineViewModel');

  final MedicineRepository _medicineRepository;

  List<Medicine> _medicines = [];
  String _searchQuery = '';
  String? _errorMessage;

  MedicineViewModel({
    MedicineRepository? medicineRepository,
  })  : _medicineRepository = medicineRepository ?? locator<MedicineRepository>();

  List<Medicine> get medicines {
    if (_searchQuery.isEmpty) return List.unmodifiable(_medicines);
    return List.unmodifiable(
      _medicines.where(
        (m) => m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (m.doctorName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false),
      ),
    );
  }

  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  bool get isLoading => state == ViewState.busy;
  bool get hasError => state == ViewState.error;
  bool get isEmpty => !isLoading && !hasError && medicines.isEmpty;

  Future<void> loadMedicines() async {
    _errorMessage = null;
    setState(ViewState.busy);
    try {
      _medicines = await _medicineRepository.getAllMedicines();
      for (final med in _medicines) {
        await med.reminders.load();
      }
      log.i('@loadMedicines: Loaded ${_medicines.length} medicines');
      setState(ViewState.idle);
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      log.e('@loadMedicines: Failed to load medicines', e, stackTrace);
      setState(ViewState.error);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> deleteMedicine(int medicineId) async {
    try {
      log.d('@deleteMedicine: Deleting medicine ID: $medicineId');
      await _medicineRepository.deleteMedicine(medicineId);
      _medicines.removeWhere((m) => m.id == medicineId);
      notifyListeners();
    } catch (e, stackTrace) {
      log.e('@deleteMedicine: Failed to delete medicine', e, stackTrace);
      rethrow;
    }
  }
}
