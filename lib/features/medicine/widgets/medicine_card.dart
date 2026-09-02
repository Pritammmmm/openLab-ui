import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/config/app_theme.dart';
import '../data/medicine_model.dart';

/// Palette for medicine accent colors — cycles by ID.
const _medicineColors = [
  Color(0xFF5F33E1), // purple
  Color(0xFF1E88E5), // blue
  Color(0xFF00897B), // teal
  Color(0xFFE65100), // deep orange
  Color(0xFFC62828), // red
  Color(0xFF6A1B9A), // deep purple
];

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  Color get _accentColor =>
      _medicineColors[medicine.id % _medicineColors.length];

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(medicine.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        onDelete();
        return false; // We handle deletion via dialog
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Row: Icon + Name + Toggle ──
              Row(
                children: [
                  // Colored medicine icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.medication_rounded,
                      size: 22,
                      color: _accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + dosage
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (medicine.dosage != null &&
                            medicine.dosage!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            medicine.dosage!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Delete
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onDelete();
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 17,
                        color: AppColors.red.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Toggle
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onToggle();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: 48,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: medicine.isActive
                            ? AppColors.green
                            : AppColors.surfaceBorder,
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        alignment: medicine.isActive
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Time Pills Row ──
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: medicine.times.map((t) {
                  final parts = t.split(':');
                  final h = int.tryParse(parts[0]) ?? 0;
                  final m = int.tryParse(parts[1]) ?? 0;
                  final period = h >= 12 ? 'PM' : 'AM';
                  final displayH =
                      h > 12 ? h - 12 : (h == 0 ? 12 : h);
                  final displayM = m.toString().padLeft(2, '0');

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.surfaceBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: _accentColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$displayH:$displayM $period',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),

              // ── Schedule + Frequency info ──
              Row(
                children: [
                  Icon(
                    Icons.repeat_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    medicine.scheduleLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    medicine.frequencyLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
