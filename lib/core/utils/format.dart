/// Formats a duration in minutes as "Xh Ym" (e.g. "6h 30m").
String formatDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return '${h}h ${m}m';
}
