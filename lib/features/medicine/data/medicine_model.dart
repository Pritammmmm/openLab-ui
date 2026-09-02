class Medicine {
  const Medicine({
    required this.id,
    required this.name,
    this.dosage,
    required this.times,
    required this.repeatDays,
    required this.isActive,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String? dosage;

  /// Stored as "HH:mm" strings (for example ["08:00", "20:00"]).
  final List<String> times;

  /// 0 = Mon, 1 = Tue, ... 6 = Sun. Empty list means every day.
  final List<int> repeatDays;
  final bool isActive;
  final DateTime createdAt;

  bool get isDaily => repeatDays.isEmpty;

  String get scheduleLabel {
    if (isDaily) return 'Every day';
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = List<int>.from(repeatDays)..sort();
    return sorted.map((d) => dayNames[d]).join(', ');
  }

  String get frequencyLabel {
    final count = times.length;
    if (count == 1) return 'Once daily';
    if (count == 2) return 'Twice daily';
    return '$count times daily';
  }

  Medicine copyWith({
    int? id,
    String? name,
    String? dosage,
    List<String>? times,
    List<int>? repeatDays,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      times: times ?? this.times,
      repeatDays: repeatDays ?? this.repeatDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
