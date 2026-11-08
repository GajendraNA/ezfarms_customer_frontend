import 'package:intl/intl.dart';

final _money = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
final _date = DateFormat('d MMM yyyy');

double toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

String formatMoney(dynamic value) {
  if (value == null) return 'N/A';
  return _money.format(toDouble(value));
}

/// Formats a weight without a trailing ".0" (e.g. 2 kg, 2.5 kg).
String formatKg(dynamic value) {
  if (value == null) return 'N/A';
  final v = toDouble(value);
  final text = v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
  return '$text kg';
}

DateTime? parseDate(dynamic value) {
  if (value is String) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is List && value.length >= 3) {
    // Some Java backends send LocalDate as [yyyy, mm, dd].
    return DateTime(value[0], value[1], value[2]);
  }
  return null;
}

String formatDate(dynamic value) {
  final date = parseDate(value);
  if (date != null) return _date.format(date);
  return value?.toString() ?? 'N/A';
}

/// Date only, as the backend's LocalDate fields expect (yyyy-MM-dd).
String apiDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
