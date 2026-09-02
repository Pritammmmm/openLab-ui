import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_theme.dart';
import '../data/health_database.dart' as db;
import '../models/health_metric_type.dart';
import '../providers/food_log_provider.dart';
import '../providers/food_search_provider.dart';
import '../providers/nutrition_goal_provider.dart';
import '../widgets/health_card.dart';

class HealthFoodTrackerScreen extends ConsumerWidget {
  const HealthFoodTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(todayFoodEntriesProvider);
    final goalState = ref.watch(nutritionGoalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Food Tracker',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 22),
            tooltip: 'Set Goal',
            onPressed: () => _showGoalSetup(context, ref, goalState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => _FoodSearchScreen(parentRef: ref),
          ),
        ),
        backgroundColor: AppColors.green,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: entriesAsync.when(
        data: (entries) {
          final total = entries.fold<int>(0, (s, e) => s + e.calories);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (!goalState.isConfigured)
                _SetupGoalBanner(
                  onTap: () => _showGoalSetup(context, ref, goalState),
                ),
              if (!goalState.isConfigured) const SizedBox(height: 16),
              _CalorieSummaryCard(
                consumed: total,
                goal: goalState.calorieTarget,
                fitnessGoal: goalState.fitnessGoal,
                onGoalTap: () => _showGoalSetup(context, ref, goalState),
              ),
              const SizedBox(height: 24),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.restaurant_rounded,
                            size: 48,
                            color: AppColors.textMuted.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        const Text('No meals logged today',
                            style: TextStyle(
                                fontSize: 16, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        const Text('Tap + to add food',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                )
              else ...[
                const Text(
                  'Today\'s meals',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _FoodItemCard(
                        entry: e,
                        onDismissed: () =>
                            ref.read(foodLogActionsProvider).delete(e.id),
                      ),
                    )),
              ],
              const SizedBox(height: 100),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Something went wrong')),
      ),
    );
  }

  void _showGoalSetup(
      BuildContext context, WidgetRef ref, NutritionGoalState current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _GoalSetupSheet(
        current: current,
        onSave: (goal, calories) {
          ref
              .read(nutritionGoalProvider.notifier)
              .update(fitnessGoal: goal, calorieTarget: calories);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ─── Full-screen food search (Samsung Health / Apple Health style) ───────────

class _FoodSearchScreen extends ConsumerStatefulWidget {
  final WidgetRef parentRef;
  const _FoodSearchScreen({required this.parentRef});

  @override
  ConsumerState<_FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<_FoodSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;
  List<FoodSearchResult> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _errorMsg;
  var _selectedMeal = MealType.breakfast;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(foodSearchQueryProvider.notifier).state = query.trim();
    });
  }

  void _onFoodSelected(FoodSearchResult food) {
    _searchFocus.unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ServingPickerSheet(
        food: food,
        mealType: _selectedMeal,
        onAdd: (name, calories, mealType) {
          widget.parentRef.read(foodLogActionsProvider).add(
                name: name,
                calories: calories,
                mealType: mealType,
              );
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showManualEntry() {
    _searchFocus.unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ManualEntrySheet(
        mealType: _selectedMeal,
        onAdd: (name, calories, mealType) {
          widget.parentRef.read(foodLogActionsProvider).add(
                name: name,
                calories: calories,
                mealType: mealType,
              );
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(foodSearchResultsProvider, (_, next) {
      next.when(
        data: (results) {
          if (mounted) {
            setState(() {
              _results = results;
              _isSearching = false;
              _hasSearched = true;
              _errorMsg = null;
            });
          }
        },
        loading: () {
          if (mounted) {
            setState(() {
              _isSearching = true;
              _errorMsg = null;
            });
          }
        },
        error: (e, _) {
          if (mounted) {
            setState(() {
              _isSearching = false;
              _hasSearched = true;
              _errorMsg = e.toString();
            });
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Food',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _showManualEntry,
            child: const Text(
              'Manual',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.green,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Meal type selector
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: MealType.values.map((t) {
                  final sel = t == _selectedMeal;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMeal = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.green
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: sel
                              ? null
                              : Border.all(color: AppColors.surfaceBorder),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(t.icon,
                                size: 16,
                                color: sel ? Colors.white : AppColors.textMuted),
                            const SizedBox(width: 6),
                            Text(
                              t.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    sel ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search foods... e.g. "rice", "chicken"',
                hintStyle: const TextStyle(
                    color: AppColors.textMuted, fontSize: 15),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textMuted, size: 22),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.textMuted, size: 20),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onQueryChanged('');
                          _searchFocus.requestFocus();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.green, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Results area
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.green),
                  )
                : _results.isNotEmpty
                    ? _buildResultsList()
                    : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: _results.length,
      itemBuilder: (_, i) {
        final food = _results[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => _onFoodSelected(food),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.restaurant_rounded,
                          color: AppColors.green, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            food.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${food.caloriesPer100g}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.green,
                            ),
                          ),
                          const Text(
                            'kcal/100g',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    if (_hasSearched && _searchCtrl.text.trim().length >= 2) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                _errorMsg != null
                    ? Icons.cloud_off_rounded
                    : Icons.search_off_rounded,
                size: 56,
                color: AppColors.textMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              _errorMsg != null ? 'Could not reach server' : 'No foods found',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMsg != null
                  ? 'Check your connection and try again'
                  : 'Try a different keyword or add manually',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _showManualEntry,
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Add Manually'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fastfood_rounded,
                size: 56, color: AppColors.textMuted.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text(
              'Search for foods',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Type a food name to see all variants\nwith calorie information',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Serving size picker (shown when user taps a search result) ─────────────

class _ServingPickerSheet extends StatefulWidget {
  final FoodSearchResult food;
  final MealType mealType;
  final void Function(String name, int calories, String mealType) onAdd;

  const _ServingPickerSheet({
    required this.food,
    required this.mealType,
    required this.onAdd,
  });

  @override
  State<_ServingPickerSheet> createState() => _ServingPickerSheetState();
}

class _ServingPickerSheetState extends State<_ServingPickerSheet> {
  late final TextEditingController _servingCtrl;
  static const _presets = [50, 100, 150, 200, 250];
  late int _servingGrams;

  @override
  void initState() {
    super.initState();
    _servingGrams = 100;
    _servingCtrl = TextEditingController(text: '100');
  }

  @override
  void dispose() {
    _servingCtrl.dispose();
    super.dispose();
  }

  int get _computedCalories =>
      (widget.food.caloriesPer100g * _servingGrams / 100).round();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Food info header
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.restaurant_rounded,
                    color: AppColors.green, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.food.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.food.category} · ${widget.food.caloriesPer100g} kcal/100g',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Serving size label
          const Text(
            'Serving size (grams)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          // Preset chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((g) {
              final sel = g == _servingGrams;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _servingGrams = g;
                    _servingCtrl.text = g.toString();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.green : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: sel
                        ? null
                        : Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Text(
                    '${g}g',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Custom input
          TextField(
            controller: _servingCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) {
              final g = int.tryParse(v);
              if (g != null && g > 0) setState(() => _servingGrams = g);
            },
            decoration: InputDecoration(
              hintText: 'Or enter custom amount',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              suffixText: 'grams',
              suffixStyle: const TextStyle(
                  color: AppColors.textMuted, fontSize: 14),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),

          // Computed calories display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.green.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: AppColors.green, size: 22),
                const SizedBox(width: 8),
                Text(
                  '$_computedCalories kcal',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
                Text(
                  '  for ${_servingGrams}g',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Add button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                widget.onAdd(
                  '${widget.food.name} (${_servingGrams}g)',
                  _computedCalories,
                  widget.mealType.name,
                );
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                'Add to ${widget.mealType.label}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Manual entry fallback ──────────────────────────────────────────────────

class _ManualEntrySheet extends StatefulWidget {
  final MealType mealType;
  final void Function(String name, int calories, String mealType) onAdd;

  const _ManualEntrySheet({required this.mealType, required this.onAdd});

  @override
  State<_ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<_ManualEntrySheet> {
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Add Manually',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Food name',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.restaurant_rounded,
                  color: AppColors.textMuted, size: 20),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _calCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Calories (kcal)',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.local_fire_department_rounded,
                  color: AppColors.textMuted, size: 20),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                final name = _nameCtrl.text.trim();
                final cal = int.tryParse(_calCtrl.text) ?? 0;
                if (name.isNotEmpty && cal > 0) {
                  widget.onAdd(name, cal, widget.mealType.name);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Add to ${widget.mealType.label}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ─────────────────────────────────────────────────────────

class _SetupGoalBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _SetupGoalBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.primary.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.flag_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set your fitness goal',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Cutting, bulking, or maintenance?',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _CalorieSummaryCard extends StatelessWidget {
  final int consumed;
  final int goal;
  final FitnessGoal fitnessGoal;
  final VoidCallback onGoalTap;

  const _CalorieSummaryCard({
    required this.consumed,
    required this.goal,
    required this.fitnessGoal,
    required this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (goal - consumed).clamp(0, goal);
    final over = consumed > goal ? consumed - goal : 0;
    final progress = (consumed / goal).clamp(0.0, 1.0);

    return HealthCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          fitnessGoal.color.withValues(alpha: 0.06),
          Colors.white,
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onGoalTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: fitnessGoal.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(fitnessGoal.icon,
                              size: 14, color: fitnessGoal.color),
                          const SizedBox(width: 4),
                          Text(
                            fitnessGoal.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: fitnessGoal.color,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.edit_rounded,
                              size: 10, color: fitnessGoal.color),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$consumed kcal',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'of $goal kcal goal',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: over > 0
                      ? AppColors.red.withValues(alpha: 0.1)
                      : AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      over > 0 ? '+$over' : '$remaining',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: over > 0 ? AppColors.red : AppColors.green,
                      ),
                    ),
                    Text(
                      over > 0 ? 'over' : 'left',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: over > 0 ? AppColors.red : AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: fitnessGoal.color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(
                progress > 1.0
                    ? AppColors.red
                    : progress > 0.9
                        ? AppColors.yellow
                        : fitnessGoal.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Goal setup bottom sheet ───────────────────────────────────────────────

class _GoalSetupSheet extends StatefulWidget {
  final NutritionGoalState current;
  final void Function(FitnessGoal goal, int calories) onSave;

  const _GoalSetupSheet({required this.current, required this.onSave});

  @override
  State<_GoalSetupSheet> createState() => _GoalSetupSheetState();
}

class _GoalSetupSheetState extends State<_GoalSetupSheet> {
  late FitnessGoal _selectedGoal;
  late TextEditingController _calCtrl;

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.current.fitnessGoal;
    _calCtrl = TextEditingController(
      text: widget.current.isConfigured
          ? widget.current.calorieTarget.toString()
          : _selectedGoal.suggestedDefault.toString(),
    );
  }

  @override
  void dispose() {
    _calCtrl.dispose();
    super.dispose();
  }

  void _onGoalChanged(FitnessGoal goal) {
    setState(() {
      _selectedGoal = goal;
      _calCtrl.text = goal.suggestedDefault.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your Fitness Goal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'This helps us set the right calorie target for you',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          ...FitnessGoal.values.map((goal) {
            final selected = goal == _selectedGoal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _onGoalChanged(goal),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? goal.color.withValues(alpha: 0.06)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? goal.color
                          : AppColors.surfaceBorder,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: goal.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Icon(goal.icon, color: goal.color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? goal.color
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              goal.description,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${goal.suggestedMin}–${goal.suggestedMax}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: selected ? goal.color : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (selected)
                        Icon(Icons.check_circle_rounded,
                            color: goal.color, size: 22)
                      else
                        Icon(Icons.circle_outlined,
                            color: AppColors.surfaceBorder, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          const Text(
            'Daily Calorie Target',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Suggested: ${_selectedGoal.suggestedMin}–${_selectedGoal.suggestedMax} kcal',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _calCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'e.g. 2000',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              suffixText: 'kcal',
              suffixStyle: const TextStyle(
                  color: AppColors.textMuted, fontSize: 14),
              prefixIcon: Icon(Icons.local_fire_department_rounded,
                  color: _selectedGoal.color, size: 22),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                final cal = int.tryParse(_calCtrl.text.trim());
                if (cal != null && cal > 0) {
                  widget.onSave(_selectedGoal, cal);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: _selectedGoal.color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Save Goal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final db.FoodEntry entry;
  final VoidCallback onDismissed;

  const _FoodItemCard({required this.entry, required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    final mealType = MealType.values.firstWhere(
      (t) => t.name == entry.mealType,
      orElse: () => MealType.breakfast,
    );

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(mealType.icon, color: AppColors.green, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${mealType.label} · ${DateFormat('h:mm a').format(entry.consumedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${entry.calories} kcal',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
