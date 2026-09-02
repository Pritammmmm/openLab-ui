import 'package:flutter/material.dart';

enum HealthMetricType {
  bloodSugar,
  bloodPressure,
  weight,
  cholesterol,
  heartRate,
  spo2,
  temperature;

  String get label => switch (this) {
        bloodSugar => 'Blood Sugar',
        bloodPressure => 'Blood Pressure',
        weight => 'Weight',
        cholesterol => 'Cholesterol',
        heartRate => 'Heart Rate',
        spo2 => 'SpO₂',
        temperature => 'Temperature',
      };

  String get unit => switch (this) {
        bloodSugar => 'mg/dL',
        bloodPressure => 'mmHg',
        weight => 'kg',
        cholesterol => 'mg/dL',
        heartRate => 'bpm',
        spo2 => '%',
        temperature => '°F',
      };

  IconData get icon => switch (this) {
        bloodSugar => Icons.bloodtype_rounded,
        bloodPressure => Icons.monitor_heart_rounded,
        weight => Icons.monitor_weight_rounded,
        cholesterol => Icons.science_rounded,
        heartRate => Icons.favorite_rounded,
        spo2 => Icons.air_rounded,
        temperature => Icons.thermostat_rounded,
      };

  Color get color => switch (this) {
        bloodSugar => const Color(0xFFEF5350),
        bloodPressure => const Color(0xFFE91E63),
        weight => const Color(0xFF5F33E1),
        cholesterol => const Color(0xFFFFA726),
        heartRate => const Color(0xFFFF5252),
        spo2 => const Color(0xFF4FC3F7),
        temperature => const Color(0xFF66BB6A),
      };
}

enum BloodSugarSubType {
  fasting,
  postMeal,
  random,
  hba1c;

  String get label => switch (this) {
        fasting => 'Fasting',
        postMeal => 'Post Meal',
        random => 'Random',
        hba1c => 'HbA1c',
      };
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get label => switch (this) {
        breakfast => 'Breakfast',
        lunch => 'Lunch',
        dinner => 'Dinner',
        snack => 'Snack',
      };

  IconData get icon => switch (this) {
        breakfast => Icons.free_breakfast_rounded,
        lunch => Icons.lunch_dining_rounded,
        dinner => Icons.dinner_dining_rounded,
        snack => Icons.cookie_rounded,
      };
}

enum MetricSource {
  manual,
  googleFit,
  samsungHealth,
  appleHealth;

  String get label => switch (this) {
        manual => 'Manual',
        googleFit => 'Google Fit',
        samsungHealth => 'Samsung Health',
        appleHealth => 'Apple Health',
      };
}
