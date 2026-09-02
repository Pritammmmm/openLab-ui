class StepsData {
  final int current;
  final int goal;
  final DateTime? date;

  const StepsData({
    required this.current,
    required this.goal,
    this.date,
  });

  double get progress => (current / goal).clamp(0.0, 1.0);
}

class CalorieData {
  final int consumed;
  final int goal;

  const CalorieData({required this.consumed, required this.goal});

  double get progress => (consumed / goal).clamp(0.0, 1.0);
  int get remaining => (goal - consumed).clamp(0, goal);
}

class WaterData {
  final int glasses;
  final int goal;

  const WaterData({required this.glasses, required this.goal});

  double get progress => (glasses / goal).clamp(0.0, 1.0);
}

class GoalData {
  final String title;
  final String subtitle;
  final double progress;
  final String currentValue;
  final String targetValue;

  const GoalData({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.currentValue,
    required this.targetValue,
  });
}

class FoodEntry {
  final String name;
  final int calories;
  final String time;
  final String icon;

  const FoodEntry({
    required this.name,
    required this.calories,
    required this.time,
    this.icon = '🍽️',
  });
}

class DailySteps {
  final String day;
  final int steps;

  const DailySteps({required this.day, required this.steps});
}
