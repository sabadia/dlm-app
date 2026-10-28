/// How long ago something was, as a number and a unit the UI localises.
enum RelativeKind {
  /// Less than a minute ago (or in the future by clock skew).
  justNow,

  /// [RelativeTime.count] minutes ago.
  minutes,

  /// [RelativeTime.count] hours ago.
  hours,

  /// Yesterday.
  yesterday,

  /// [RelativeTime.count] days ago (2 to 6).
  days,

  /// A week or more ago: show the date.
  date,
}

/// The result of [relativeTime].
class RelativeTime {
  /// Creates a value.
  const RelativeTime(this.kind, [this.count = 0]);

  /// Which phrase.
  final RelativeKind kind;

  /// The number in the phrase.
  final int count;

  @override
  bool operator ==(Object other) =>
      other is RelativeTime && other.kind == kind && other.count == count;

  @override
  int get hashCode => Object.hash(kind, count);

  @override
  String toString() => 'RelativeTime(${kind.name}, $count)';
}

/// Classifies [time] relative to [now] (both converted to the local calendar
/// for "yesterday").
RelativeTime relativeTime(DateTime time, DateTime now) {
  final diff = now.difference(time);
  if (diff.inSeconds < 60) return const RelativeTime(RelativeKind.justNow);
  if (diff.inMinutes < 60) {
    return RelativeTime(RelativeKind.minutes, diff.inMinutes);
  }
  final t = time.toLocal();
  final n = now.toLocal();
  final days = DateTime(
    n.year,
    n.month,
    n.day,
  ).difference(DateTime(t.year, t.month, t.day)).inDays;
  if (days == 0) return RelativeTime(RelativeKind.hours, diff.inHours);
  if (days == 1) return const RelativeTime(RelativeKind.yesterday);
  if (days < 7) return RelativeTime(RelativeKind.days, days);
  return const RelativeTime(RelativeKind.date);
}
