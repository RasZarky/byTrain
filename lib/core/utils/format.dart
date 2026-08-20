import 'package:intl/intl.dart';

/// Formats a duration in minutes as "Xh Ym" (e.g. "6h 30m").
String formatDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return '${h}h ${m}m';
}

final _clock12 = DateFormat('h:mm a', 'en_US');
final _dateWithClock12 = DateFormat('EEE, d MMM · h:mm a', 'en_US');

/// Clock time in 12-hour form, e.g. "2:30 PM".
String formatClockTime(DateTime dt) => _clock12.format(dt);

/// Date plus 12-hour clock, e.g. "Thu, 20 Aug · 2:30 PM".
String formatDateWithClock(DateTime dt) => _dateWithClock12.format(dt);

/// Converts a timetable `HH:mm` string (or `--:--`) to 12-hour form.
String formatClockTimeString(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty || trimmed == '--:--') return trimmed;
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
  if (match == null) return raw;
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  if (hour > 23 || minute > 59) return raw;
  return formatClockTime(DateTime(2000, 1, 1, hour, minute));
}
