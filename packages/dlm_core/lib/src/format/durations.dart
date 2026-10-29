/// Writes a duration with at most two units, `2 d 3 h`, `1 h 5 min`,
/// `45 s`; `< 1 s` below a second. The unit abbreviations are the same in
/// every language (as in most file managers).
String formatDuration(Duration d) {
  final total = d.inSeconds;
  if (d.isNegative) return formatDuration(-d);
  if (total < 1) return '< 1 s';
  final days = total ~/ 86400;
  final hours = total % 86400 ~/ 3600;
  final minutes = total % 3600 ~/ 60;
  final seconds = total % 60;
  if (days > 0) return hours > 0 ? '$days d $hours h' : '$days d';
  if (hours > 0) return minutes > 0 ? '$hours h $minutes min' : '$hours h';
  if (minutes > 0) {
    return seconds > 0 && minutes < 10
        ? '$minutes min $seconds s'
        : '$minutes min';
  }
  return '$seconds s';
}

/// The remaining time, or null when it is unknown (no size, no speed): the
/// daemon reports an ETA of `0` or less then.
String? formatEta(int? seconds) => seconds == null || seconds <= 0
    ? null
    : formatDuration(Duration(seconds: seconds));

/// The remaining time computed from progress; null while unknown.
Duration? estimateRemaining({
  required int downloaded,
  required int size,
  required int bytesPerSecond,
}) {
  if (size < 0 || bytesPerSecond <= 0 || downloaded >= size) return null;
  return Duration(seconds: ((size - downloaded) / bytesPerSecond).ceil());
}

/// Reads a duration a person typed: `90`, `90s`, `1h30m`, `1h 30 min`,
/// `2d`, `1:30:00`, `5:00`. A bare number is seconds. Null for anything else.
Duration? parseDuration(String input) {
  final text = input.trim().toLowerCase();
  if (text.isEmpty) return null;
  final clock = RegExp(r'^(?:(\d+):)?(\d{1,2}):(\d{2})$').firstMatch(text);
  if (clock != null) {
    final hours = clock.group(1);
    final a = int.parse(clock.group(2)!);
    final s = int.parse(clock.group(3)!);
    if (s > 59 || (hours != null && a > 59)) return null;
    return hours == null
        ? Duration(minutes: a, seconds: s)
        : Duration(hours: int.parse(hours), minutes: a, seconds: s);
  }
  if (RegExp(r'^\d+$').hasMatch(text)) {
    return Duration(seconds: int.parse(text));
  }
  final part = RegExp(r'(\d+)\s*(d|h|min|m|s)(?![a-z])');
  var rest = text;
  var total = Duration.zero;
  var any = false;
  for (final m in part.allMatches(text)) {
    final n = int.parse(m.group(1)!);
    total += switch (m.group(2)) {
      'd' => Duration(days: n),
      'h' => Duration(hours: n),
      's' => Duration(seconds: n),
      _ => Duration(minutes: n),
    };
    rest = rest.replaceFirst(m.group(0)!, '');
    any = true;
  }
  return any && rest.trim().isEmpty ? total : null;
}
