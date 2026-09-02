import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyStepGoal = 'daily_step_goal';
const _defaultGoal = 10000;

final stepGoalProvider =
    AsyncNotifierProvider<StepGoalNotifier, int>(StepGoalNotifier.new);

class StepGoalNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStepGoal) ?? _defaultGoal;
  }

  Future<void> setGoal(int goal) async {
    if (goal < 100) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStepGoal, goal);
    state = AsyncData(goal);
  }
}
