import '../../health/data/health_database.dart';
import 'medicine_model.dart';

class MedicineRepository {
  const MedicineRepository(this._db);

  final HealthDatabase _db;

  Stream<List<Medicine>> watchAll() {
    return _db.watchMedicines();
  }

  Future<List<Medicine>> getAll() {
    return _db.getAllMedicines();
  }

  Future<Medicine?> getById(int id) {
    return _db.getMedicineById(id);
  }

  Future<int> add(Medicine medicine) {
    return _db.insertMedicine(medicine);
  }

  Future<void> update(Medicine medicine) {
    return _db.updateMedicine(medicine);
  }

  Future<void> toggleActive(int id) async {
    final med = await _db.getMedicineById(id);
    if (med == null) return;

    await _db.updateMedicine(
      med.copyWith(isActive: !med.isActive),
    );
  }

  Future<bool> delete(int id) {
    return _db.deleteMedicine(id);
  }
}
