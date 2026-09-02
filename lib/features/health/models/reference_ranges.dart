import 'health_metric_type.dart';

enum RangeStatus { normal, borderline, high, low }

class ReferenceRange {
  final double low;
  final double normal;
  final double borderline;
  final String unit;

  const ReferenceRange({
    required this.low,
    required this.normal,
    required this.borderline,
    required this.unit,
  });

  RangeStatus evaluate(double value) {
    if (value < low) return RangeStatus.low;
    if (value <= normal) return RangeStatus.normal;
    if (value <= borderline) return RangeStatus.borderline;
    return RangeStatus.high;
  }
}

class HealthRanges {
  HealthRanges._();

  static const bloodSugarFasting = ReferenceRange(
    low: 70,
    normal: 100,
    borderline: 125,
    unit: 'mg/dL',
  );

  static const bloodSugarPostMeal = ReferenceRange(
    low: 70,
    normal: 140,
    borderline: 199,
    unit: 'mg/dL',
  );

  static const hba1c = ReferenceRange(
    low: 4.0,
    normal: 5.7,
    borderline: 6.4,
    unit: '%',
  );

  static const systolic = ReferenceRange(
    low: 90,
    normal: 120,
    borderline: 139,
    unit: 'mmHg',
  );

  static const diastolic = ReferenceRange(
    low: 60,
    normal: 80,
    borderline: 89,
    unit: 'mmHg',
  );

  static const heartRate = ReferenceRange(
    low: 50,
    normal: 100,
    borderline: 120,
    unit: 'bpm',
  );

  static const spo2 = ReferenceRange(
    low: 90,
    normal: 100,
    borderline: 100,
    unit: '%',
  );

  static const cholesterolTotal = ReferenceRange(
    low: 0,
    normal: 200,
    borderline: 239,
    unit: 'mg/dL',
  );

  static const cholesterolHdl = ReferenceRange(
    low: 40,
    normal: 200,
    borderline: 200,
    unit: 'mg/dL',
  );

  static const cholesterolLdl = ReferenceRange(
    low: 0,
    normal: 100,
    borderline: 159,
    unit: 'mg/dL',
  );

  static RangeStatus evaluateBloodSugar(
    double value,
    BloodSugarSubType subType,
  ) {
    return switch (subType) {
      BloodSugarSubType.fasting => bloodSugarFasting.evaluate(value),
      BloodSugarSubType.postMeal => bloodSugarPostMeal.evaluate(value),
      BloodSugarSubType.hba1c => hba1c.evaluate(value),
      BloodSugarSubType.random => bloodSugarFasting.evaluate(value),
    };
  }

  static RangeStatus evaluateBloodPressure(double systolicVal, double diastolicVal) {
    final sys = systolic.evaluate(systolicVal);
    final dia = diastolic.evaluate(diastolicVal);
    if (sys == RangeStatus.high || dia == RangeStatus.high) return RangeStatus.high;
    if (sys == RangeStatus.borderline || dia == RangeStatus.borderline) {
      return RangeStatus.borderline;
    }
    if (sys == RangeStatus.low || dia == RangeStatus.low) return RangeStatus.low;
    return RangeStatus.normal;
  }

  static RangeStatus evaluateHeartRate(double value) =>
      heartRate.evaluate(value);
}
