import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../data/medicine_model.dart';
import '../providers/medicine_provider.dart';

class AddMedicineSheet extends ConsumerStatefulWidget {
  final Medicine? existing;

  const AddMedicineSheet({super.key, this.existing});

  @override
  ConsumerState<AddMedicineSheet> createState() =>
      _AddMedicineSheetState();
}

class _AddMedicineSheetState extends ConsumerState<AddMedicineSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _dosageCtrl;
  final _formKey = GlobalKey<FormState>();

  List<TimeOfDay> _selectedTimes = [];
  Set<int> _selectedDays = {}; // empty = every day

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final med = widget.existing;
    _nameCtrl = TextEditingController(text: med?.name ?? '');
    _dosageCtrl = TextEditingController(text: med?.dosage ?? '');

    if (med != null) {
      _selectedTimes = med.times.map((t) {
        final parts = t.split(':');
        return TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }).toList();
      _selectedDays = med.repeatDays.toSet();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Drag handle ──
                  Center(
                    child: Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Title ──
                  Text(
                    _isEditing ? 'Edit Reminder' : 'New Reminder',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isEditing
                        ? 'Update your medicine details'
                        : 'Set up your medicine reminder',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Medicine Name ──
                  _FieldLabel(label: 'Medicine Name'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Vitamin D3',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.medication_rounded,
                          size: 20,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Enter medicine name'
                            : null,
                  ),
                  const SizedBox(height: 20),

                  // ── Dosage (optional) ──
                  _FieldLabel(label: 'Dosage', optional: true),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _dosageCtrl,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. 500mg',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.science_outlined,
                          size: 20,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Reminder Times ──
                  Row(
                    children: [
                      const _FieldLabel(label: 'Reminder Times'),
                      const Spacer(),
                      GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 16, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'Add Time',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedTimes.isEmpty)
                    GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.surfaceBorder,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 28,
                              color: AppColors.textMuted.withValues(
                                  alpha: 0.5),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to add a time',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedTimes
                          .asMap()
                          .entries
                          .map((entry) {
                        final idx = entry.key;
                        final t = entry.value;
                        return _TimeChip(
                          time: t,
                          onRemove: () {
                            setState(() =>
                                _selectedTimes.removeAt(idx));
                          },
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // ── Repeat Days ──
                  const _FieldLabel(label: 'Repeat'),
                  const SizedBox(height: 4),
                  Text(
                    _selectedDays.isEmpty
                        ? 'Every day'
                        : 'Custom days',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DaySelector(
                    selectedDays: _selectedDays,
                    onChanged: (days) {
                      setState(() => _selectedDays = days);
                    },
                  ),
                  const SizedBox(height: 32),

                  // ── Save Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _save,
                          child: Center(
                            child: Text(
                              _isEditing
                                  ? 'Update Reminder'
                                  : 'Add Reminder',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (time != null) {
      HapticFeedback.selectionClick();
      setState(() => _selectedTimes.add(time));
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one reminder time')),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final actions = ref.read(medicineActionsProvider);
    final timeStrings = _selectedTimes
        .map((t) =>
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .toList()
      ..sort();

    if (_isEditing) {
      final sortedDays = _selectedDays.toList()..sort();
      final med = widget.existing!.copyWith(
        name: _nameCtrl.text.trim(),
        dosage:
            _dosageCtrl.text.trim().isEmpty ? null : _dosageCtrl.text.trim(),
        times: List.unmodifiable(timeStrings),
        repeatDays: List.unmodifiable(sortedDays),
      );
      actions.update(med);
    } else {
      actions.add(
        name: _nameCtrl.text.trim(),
        dosage: _dosageCtrl.text.trim().isEmpty
            ? null
            : _dosageCtrl.text.trim(),
        times: timeStrings,
        repeatDays: _selectedDays.toList()..sort(),
      );
    }

    Navigator.pop(context);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool optional;

  const _FieldLabel({required this.label, this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          Text(
            '(optional)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback onRemove;

  const _TimeChip({required this.time, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return Container(
      padding: const EdgeInsets.only(left: 14, right: 6, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '$h:$m $period',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 13,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  final Set<int> selectedDays;
  final ValueChanged<Set<int>> onChanged;

  const _DaySelector({
    required this.selectedDays,
    required this.onChanged,
  });

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isSelected =
            selectedDays.isEmpty || selectedDays.contains(index);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            final newDays = Set<int>.from(selectedDays);

            if (selectedDays.isEmpty) {
              // Currently "every day" → switching to custom, select all except tapped
              newDays.addAll(List.generate(7, (i) => i));
              newDays.remove(index);
            } else if (newDays.contains(index)) {
              newDays.remove(index);
              // If all removed or all selected again → go back to "every day"
              if (newDays.isEmpty || newDays.length == 7) {
                onChanged({});
                return;
              }
            } else {
              newDays.add(index);
              if (newDays.length == 7) {
                onChanged({});
                return;
              }
            }
            onChanged(newDays);
          },
          child: Tooltip(
            message: _dayNames[index],
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceBorder,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary
                              .withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                _dayLabels[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textMuted,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
