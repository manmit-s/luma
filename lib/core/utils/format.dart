import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatAmount(int minor) {
  final negative = minor < 0;
  final abs = minor.abs();
  final rupees = abs ~/ 100;
  final paise = abs % 100;
  final rupeesStr = _withSeparators(rupees);
  final body = paise == 0 ? rupeesStr : '$rupeesStr.${paise.toString().padLeft(2, '0')}';
  return '${negative ? '-' : ''}₹$body';
}

String _withSeparators(int value) {
  final digits = value.toString();
  if (digits.length <= 3) return digits;
  final buffer = StringBuffer();
  final offset = digits.length % 3;
  if (offset > 0) buffer.write(digits.substring(0, offset));
  for (var i = offset; i < digits.length; i += 3) {
    if (buffer.isNotEmpty) buffer.write(',');
    buffer.write(digits.substring(i, i + 3));
  }
  return buffer.toString();
}

String formatTime(DateTime value) {
  final hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final suffix = value.hour < 12 ? 'AM' : 'PM';
  final mm = value.minute.toString().padLeft(2, '0');
  return '${value.day} ${_months[value.month - 1]}, $hour12:$mm $suffix';
}

String formatDayLabel(DateTime value, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final a = DateTime(today.year, today.month, today.day);
  final b = DateTime(value.year, value.month, value.day);
  final diff = a.difference(b).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return '${value.day} ${_months[value.month - 1]}';
}

String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String categoryName(String? id) {
  for (final category in defaultCategories) {
    if (category.id == id) return category.name;
  }
  return 'Uncategorized';
}

String merchantLabel(String? merchant) => (merchant == null || merchant.trim().isEmpty)
    ? 'Unknown merchant'
    : merchant.trim();

/// Groups expenses (expected newest-first) by calendar day, preserving order.
List<(DateTime, List<Expense>)> groupExpensesByDay(List<Expense> expenses) {
  final groups = <DateTime, List<Expense>>{};
  for (final expense in expenses) {
    final day = DateTime(
      expense.timestamp.year,
      expense.timestamp.month,
      expense.timestamp.day,
    );
    (groups[day] ??= []).add(expense);
  }
  return groups.entries.map((e) => (e.key, e.value)).toList();
}
