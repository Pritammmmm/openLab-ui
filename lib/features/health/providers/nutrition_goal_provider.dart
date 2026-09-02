import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FitnessGoal {
  cutting('Cutting', 'Lose fat, preserve muscle', Icons.trending_down_rounded, Color(0xFFFF6B35), 1500, 1800),
  maintenance('Maintenance', 'Maintain current weight', Icons.balance_rounded, Color(0xFF34C759), 1800, 2200),
  leanBulk('Lean Bulk', 'Build muscle, minimal fat', Icons.trending_up_rounded, Color(0xFF4FC3F7), 2200, 2600),
  bulk('Bulk', 'Maximum muscle gain', Icons.fitness_center_rounded, Color(0xFF5F33E1), 2600, 3200),
  recomposition('Recomposition', 'Lose fat & gain muscle', Icons.swap_vert_rounded, Color(0xFFFFAC0C), 1800, 2200);

  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final int suggestedMin;
  final int suggestedMax;

  const FitnessGoal(this.label, this.description, this.icon, this.color, this.suggestedMin, this.suggestedMax);

  int get suggestedDefault => ((suggestedMin + suggestedMax) / 2).round();
}

class NutritionGoalState {
  final FitnessGoal fitnessGoal;
  final int calorieTarget;
  final bool isConfigured;

  const NutritionGoalState({
    this.fitnessGoal = FitnessGoal.maintenance,
    this.calorieTarget = 2000,
    this.isConfigured = false,
  });

  NutritionGoalState copyWith({
    FitnessGoal? fitnessGoal,
    int? calorieTarget,
    bool? isConfigured,
  }) =>
      NutritionGoalState(
        fitnessGoal: fitnessGoal ?? this.fitnessGoal,
        calorieTarget: calorieTarget ?? this.calorieTarget,
        isConfigured: isConfigured ?? this.isConfigured,
      );
}

const _kFitnessGoal = 'nutrition_fitness_goal';
const _kCalorieTarget = 'nutrition_calorie_target';
const _kIsConfigured = 'nutrition_is_configured';

class NutritionGoalNotifier extends StateNotifier<NutritionGoalState> {
  NutritionGoalNotifier() : super(const NutritionGoalState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final goalIndex = prefs.getInt(_kFitnessGoal);
    final calories = prefs.getInt(_kCalorieTarget);
    final configured = prefs.getBool(_kIsConfigured) ?? false;

    state = NutritionGoalState(
      fitnessGoal: goalIndex != null && goalIndex < FitnessGoal.values.length
          ? FitnessGoal.values[goalIndex]
          : FitnessGoal.maintenance,
      calorieTarget: calories ?? 2000,
      isConfigured: configured,
    );
  }

  Future<void> update({
    required FitnessGoal fitnessGoal,
    required int calorieTarget,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kFitnessGoal, fitnessGoal.index);
    await prefs.setInt(_kCalorieTarget, calorieTarget);
    await prefs.setBool(_kIsConfigured, true);
    state = NutritionGoalState(
      fitnessGoal: fitnessGoal,
      calorieTarget: calorieTarget,
      isConfigured: true,
    );
  }
}

final nutritionGoalProvider =
    StateNotifierProvider<NutritionGoalNotifier, NutritionGoalState>(
  (_) => NutritionGoalNotifier(),
);
