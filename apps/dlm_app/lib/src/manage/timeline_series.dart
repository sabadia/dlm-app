import 'package:dlm_api/dlm_api.dart';

/// A traffic timeline arranged for a stacked bar chart: one column per bucket
/// of time, one stack segment per group (engine or queue; a single unnamed one
/// when the timeline is not split).
class TimelineSeries {
  TimelineSeries._(this.times, this.groups, this.down, this.up);

  /// Arranges [timeline].
  factory TimelineSeries.of(Timeline timeline) {
    final points = timeline.points ?? const <TimelinePoint>[];
    final times = <DateTime>{for (final p in points) p.time.toUtc()}.toList()
      ..sort();
    final groups = <String>{for (final p in points) p.group ?? ''}.toList()
      ..sort();
    final down = [
      for (final _ in times) {for (final g in groups) g: 0},
    ];
    final up = [
      for (final _ in times) {for (final g in groups) g: 0},
    ];
    for (final p in points) {
      final i = times.indexOf(p.time.toUtc());
      final g = p.group ?? '';
      down[i][g] = (down[i][g] ?? 0) + p.down;
      up[i][g] = (up[i][g] ?? 0) + p.up;
    }
    return TimelineSeries._(times, groups, down, up);
  }

  /// The buckets, oldest first.
  final List<DateTime> times;

  /// The groups, in the order of the stack.
  final List<String> groups;

  /// Bytes downloaded per bucket and group.
  final List<Map<String, int>> down;

  /// Bytes uploaded per bucket and group.
  final List<Map<String, int>> up;

  /// Whether the timeline has no traffic at all.
  bool get isEmpty => totalDown == 0 && totalUp == 0;

  /// Bytes downloaded in a bucket, over all groups.
  int downIn(int bucket) => down[bucket].values.fold(0, (a, b) => a + b);

  /// Bytes downloaded in the whole range.
  int get totalDown =>
      [for (var i = 0; i < times.length; i++) downIn(i)]
          .fold(0, (a, b) => a + b);

  /// Bytes uploaded in the whole range.
  int get totalUp => [for (final m in up) ...m.values].fold(0, (a, b) => a + b);

  /// The largest download of a single bucket (the height of the chart).
  int get peakDown =>
      [for (var i = 0; i < times.length; i++) downIn(i)]
          .fold(0, (a, b) => a > b ? a : b);
}
