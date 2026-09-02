import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../health/providers/health_providers.dart';
import '../data/medicine_model.dart';
import '../data/medicine_repository.dart';
import '../data/notification_service.dart';

// ── Repository singleton provider ──────────────────────────────────────────

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  return MedicineRepository(ref.watch(healthDatabaseProvider));
});

// ── Reactive medicine list ─────────────────────────────────────────────────

final medicineListProvider =
    StreamProvider.autoDispose<List<Medicine>>((ref) {
  final repo = ref.watch(medicineRepositoryProvider);
  return repo.watchAll();
});

// ── State notifier for mutations ───────────────────────────────────────────

final medicineActionsProvider =
    Provider.autoDispose<MedicineActions>((ref) {
  return MedicineActions(ref.watch(medicineRepositoryProvider));
});

class MedicineActions {
  MedicineActions(this._repo);

  final MedicineRepository _repo;
  final _notif = NotificationService.instance;

  Future<int> add({
    required String name,
    String? dosage,
    required List<String> times,
    required List<int> repeatDays,
  }) async {
    final medicine = Medicine(
      id: 0,
      name: name,
      dosage: dosage,
      times: List.unmodifiable(times),
      repeatDays: List.unmodifiable(repeatDays),
      isActive: true,
      createdAt: DateTime.now(),
    );
    final id = await _repo.add(medicine);

    // Fetch the saved medicine (with assigned ID) and schedule
    final saved = await _repo.getById(id);
    if (saved != null) {
      await _notif.scheduleMedicine(saved);
    }
    return id;
  }

  Future<void> toggleActive(int id) async {
    final before = await _repo.getById(id);
    await _repo.toggleActive(id);
    final after = await _repo.getById(id);

    if (after != null && after.isActive) {
      await _notif.scheduleMedicine(after);
    } else if (before != null) {
      await _notif.cancelMedicine(id, before.times.length);
    }
  }

  Future<bool> delete(int id) async {
    final med = await _repo.getById(id);
    if (med != null) {
      await _notif.cancelMedicine(id, med.times.length);
    }
    return _repo.delete(id);
  }

  Future<void> update(Medicine medicine) async {
    // Cancel old schedules then reschedule
    await _notif.cancelMedicine(medicine.id, medicine.times.length + 5);
    await _repo.update(medicine);
    final updated = await _repo.getById(medicine.id);
    if (updated != null && updated.isActive) {
      await _notif.scheduleMedicine(updated);
    }
  }
}
