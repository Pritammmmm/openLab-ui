import 'package:intl/intl.dart';

class Helpers {
  Helpers._();

  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatDateShort(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d').format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  static String formatRelativeDate(DateTime? date) {
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return formatDate(date);
  }

  static String formatNumber(double? value) {
    if (value == null) return 'N/A';
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  static String formatPercentage(double? value) {
    if (value == null) return 'N/A';
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}%';
  }

  static String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'green':
      case 'normal':
        return 'Normal';
      case 'yellow':
      case 'borderline':
        return 'Borderline';
      case 'red':
      case 'abnormal':
      case 'attention':
        return 'Needs Attention';
      default:
        return status;
    }
  }

  static String overallStatusMessage(String? status) {
    switch (status?.toLowerCase()) {
      case 'green':
        return 'Your results look great! Keep up the good work.';
      case 'yellow':
        return 'Some values need attention. Consider discussing with your doctor.';
      case 'red':
        return 'Some values need prompt attention. Please consult your doctor.';
      default:
        return 'Report analysis in progress.';
    }
  }

  static String trendLabel(String? trend) {
    switch (trend?.toLowerCase()) {
      case 'improved':
        return 'Improved';
      case 'stable':
        return 'Stable';
      case 'declined':
        return 'Declined';
      case 'new':
        return 'New';
      default:
        return 'N/A';
    }
  }

  static String trendIcon(String? trend) {
    switch (trend?.toLowerCase()) {
      case 'improved':
        return '↗';
      case 'stable':
        return '→';
      case 'declined':
        return '↘';
      default:
        return '';
    }
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static int calculateAge(DateTime? dob) {
    if (dob == null) return 0;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  static String firstNameFrom(String fullName) {
    return fullName.split(' ').first;
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
