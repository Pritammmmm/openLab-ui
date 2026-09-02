import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../data/medicine_model.dart';
import '../providers/medicine_provider.dart';
import '../widgets/add_medicine_sheet.dart';
import '../widgets/medicine_card.dart';

class MedicineScreen extends ConsumerWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsync = ref.watch(medicineListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // ── Premium App Bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _showAddSheet(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Reminders',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: false,
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────
          medicinesAsync.when(
            data: (medicines) {
              if (medicines.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                );
              }

              // Separate active and inactive
              final active =
                  medicines.where((m) => m.isActive).toList();
              final inactive =
                  medicines.where((m) => !m.isActive).toList();

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList.list(
                  children: [
                    // ── Next Dose Hero Card ──
                    if (active.isNotEmpty) ...[
                      _NextDoseHero(medicines: active),
                      const SizedBox(height: 24),
                    ],

                    // ── Active section ──
                    if (active.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Active',
                        count: active.length,
                      ),
                      const SizedBox(height: 12),
                      ...active.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: MedicineCard(
                              medicine: m,
                              onToggle: () => ref
                                  .read(medicineActionsProvider)
                                  .toggleActive(m.id),
                              onDelete: () => _confirmDelete(
                                  context, ref, m),
                              onTap: () =>
                                  _showEditSheet(context, m),
                            ),
                          )),
                    ],

                    // ── Inactive section ──
                    if (inactive.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionHeader(
                        title: 'Paused',
                        count: inactive.length,
                      ),
                      const SizedBox(height: 12),
                      ...inactive.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Opacity(
                              opacity: 0.55,
                              child: MedicineCard(
                                medicine: m,
                                onToggle: () => ref
                                    .read(medicineActionsProvider)
                                    .toggleActive(m.id),
                                onDelete: () => _confirmDelete(
                                    context, ref, m),
                                onTap: () =>
                                    _showEditSheet(context, m),
                              ),
                            ),
                          )),
                    ],
                  ],
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Failed to load reminders',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddMedicineSheet(),
    );
  }

  void _showEditSheet(BuildContext context, Medicine medicine) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMedicineSheet(existing: medicine),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Medicine medicine) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Reminder'),
        content: Text(
          'Delete "${medicine.name}" reminder? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(medicineActionsProvider).delete(medicine.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Next Dose Hero Card
// ─────────────────────────────────────────────────────────────────────────────

class _NextDoseHero extends StatelessWidget {
  final List<Medicine> medicines;

  const _NextDoseHero({required this.medicines});

  @override
  Widget build(BuildContext context) {
    final next = _findNextDose();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B3FE8),
            Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'NEXT DOSE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (next != null) ...[
            Text(
              next.$1,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    next.$2,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  next.$3,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ] else
            const Text(
              'No upcoming doses today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  /// Returns (medicineName, timeString, relativeLabel) for the next upcoming dose.
  (String, String, String)? _findNextDose() {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    String? bestName;
    String? bestTimeStr;
    int bestDiff = 999999;

    for (final med in medicines) {
      for (final t in med.times) {
        final parts = t.split(':');
        if (parts.length != 2) continue;
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final medMinutes = h * 60 + m;
        final diff = medMinutes - nowMinutes;

        if (diff > 0 && diff < bestDiff) {
          bestDiff = diff;
          bestName = med.name;
          final period = h >= 12 ? 'PM' : 'AM';
          final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
          final displayM = m.toString().padLeft(2, '0');
          bestTimeStr = '$displayH:$displayM $period';
        }
      }
    }

    if (bestName == null || bestTimeStr == null) return null;

    final hours = bestDiff ~/ 60;
    final mins = bestDiff % 60;
    String relative;
    if (hours > 0) {
      relative = 'in ${hours}h ${mins}m';
    } else {
      relative = 'in ${mins}m';
    }

    return (bestName, bestTimeStr, relative);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glassy pill icon
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.10),
                    AppColors.primary.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Icon(
                Icons.medication_rounded,
                size: 40,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Reminders Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your medicines and never\nmiss a dose again',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // CTA button
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const AddMedicineSheet(),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded,
                            size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Add Medicine',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
