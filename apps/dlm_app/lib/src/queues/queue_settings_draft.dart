import 'package:dlm_api/dlm_api.dart';

/// Weekday names on the wire, in grid order (Monday first).
const List<String> gridDays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

/// The shortest quota period the daemon accepts.
const Duration minQuotaPeriod = Duration(minutes: 1);

/// The longest grace period before a post-queue action.
const Duration maxActionDelay = Duration(hours: 24);

/// Writes [d] the way the daemon reads durations (`1h30m0s`).
String goDuration(Duration d) {
  final total = d.inSeconds;
  final h = total ~/ 3600;
  final m = total % 3600 ~/ 60;
  final s = total % 60;
  if (h > 0) return '${h}h${m}m${s}s';
  if (m > 0) return '${m}m${s}s';
  return '${s}s';
}

/// Reads a duration written by the daemon (`1h0m0s`, `90s`, `1.5s`); null for
/// anything else.
Duration? parseGoDuration(Object? value) {
  if (value is! String || value.isEmpty) return null;
  final part = RegExp(r'(\d+(?:\.\d+)?)(h|ms|m|s)');
  var rest = value;
  var micros = 0.0;
  for (final match in part.allMatches(value)) {
    final n = double.parse(match.group(1)!);
    micros +=
        n *
        switch (match.group(2)) {
          'h' => 3.6e9,
          'm' => 6e7,
          's' => 1e6,
          _ => 1e3,
        };
    rest = rest.replaceFirst(match.group(0)!, '');
  }
  return rest.isEmpty && micros > 0 || value == '0s'
      ? Duration(microseconds: micros.round())
      : null;
}

String _clock(int hour) => '${hour.toString().padLeft(2, '0')}:00';

/// The weekly hours a schedule or a speed profile is active, as a grid of
/// cells (`day * 24 + hour`, Monday first) that the schedule grid edits.
///
/// Windows the grid cannot show exactly (minutes, odd clock text) are kept
/// untouched in [custom] until the user chooses to replace them.
class WindowsDraft {
  /// Creates a draft from its parts.
  WindowsDraft({Set<int>? cells, this.timezone, this.custom})
    : cells = {...?cells};

  /// Reads the windows of a daemon setting.
  factory WindowsDraft.from(String? timezone, List<TimeWindow>? windows) {
    final cells = <int>{};
    for (final w in windows ?? const <TimeWindow>[]) {
      if (!_addWindow(cells, w)) {
        return WindowsDraft(timezone: timezone, custom: List.of(windows!));
      }
    }
    return WindowsDraft(cells: cells, timezone: timezone);
  }

  /// Active hours.
  final Set<int> cells;

  /// IANA zone of the windows; null means the computer's own.
  final String? timezone;

  /// Windows that need minutes, kept as they are; null when the grid is exact.
  List<TimeWindow>? custom;

  /// Whether the grid can show the windows.
  bool get exact => custom == null;

  /// Whether nothing is active.
  bool get isEmpty => exact && cells.isEmpty;

  static bool _addWindow(Set<int> cells, TimeWindow w) {
    final start = _hour(w.start);
    final end = _hour(w.end);
    final days = [
      for (final d in w.days ?? const <String>[]) gridDays.indexOf(d),
    ];
    if (start == null || end == null || start == end || days.contains(-1)) {
      return false;
    }
    for (final day in days) {
      if (start < end) {
        for (var h = start; h < end; h++) {
          cells.add(day * 24 + h);
        }
      } else {
        for (var h = start; h < 24; h++) {
          cells.add(day * 24 + h);
        }
        final next = (day + 1) % 7;
        for (var h = 0; h < end; h++) {
          cells.add(next * 24 + h);
        }
      }
    }
    return true;
  }

  static int? _hour(String clock) {
    final m = RegExp(r'^(\d{1,2}):00$').firstMatch(clock);
    final h = m == null ? null : int.parse(m.group(1)!);
    return h != null && h < 24 ? h : null;
  }

  /// Replaces the custom windows by the closest hourly grid (every touched
  /// hour counts as active).
  void useGrid(List<TimeWindow> windows) {
    custom = null;
    cells.clear();
    for (final w in windows) {
      final s = _minutes(w.start);
      final e = _minutes(w.end);
      if (s == null || e == null || s == e) continue;
      final startHour = s ~/ 60;
      final endHour = (e + 59) ~/ 60;
      for (final d in w.days ?? const <String>[]) {
        final day = gridDays.indexOf(d);
        if (day < 0) continue;
        if (s < e) {
          for (var h = startHour; h < endHour; h++) {
            cells.add(day * 24 + h);
          }
        } else {
          for (var h = startHour; h < 24; h++) {
            cells.add(day * 24 + h);
          }
          for (var h = 0; h < endHour; h++) {
            cells.add(((day + 1) % 7) * 24 + h);
          }
        }
      }
    }
  }

  static int? _minutes(String clock) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(clock);
    if (m == null) return null;
    final h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    return h < 24 && min < 60 ? h * 60 + min : null;
  }

  /// The windows to send: one per run of hours, days with the same run share
  /// a window. A run to midnight ends at `00:00`; a whole day is two windows
  /// because the daemon treats an equal start and end as empty.
  List<TimeWindow> toWindows() {
    if (custom != null) return List.of(custom!);
    final byRun = <(int, int), List<String>>{};
    for (var day = 0; day < 7; day++) {
      var h = 0;
      while (h < 24) {
        if (!cells.contains(day * 24 + h)) {
          h++;
          continue;
        }
        final from = h;
        while (h < 24 && cells.contains(day * 24 + h)) {
          h++;
        }
        if (from == 0 && h == 24) {
          byRun.putIfAbsent((0, 12), () => []).add(gridDays[day]);
          byRun.putIfAbsent((12, 24), () => []).add(gridDays[day]);
        } else {
          byRun.putIfAbsent((from, h), () => []).add(gridDays[day]);
        }
      }
    }
    final runs = byRun.keys.toList()
      ..sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
    return [
      for (final r in runs)
        TimeWindow(
          days: byRun[r],
          start: _clock(r.$1),
          end: _clock(r.$2 == 24 ? 0 : r.$2),
        ),
    ];
  }
}

/// One speed profile being edited.
class ProfileDraft {
  /// Creates a profile draft.
  ProfileDraft({required this.windows, this.speedLimit});

  /// Hours it applies.
  final WindowsDraft windows;

  /// Bytes per second; null means unlimited while active.
  int? speedLimit;
}

/// What happens when a queue finishes.
enum QueueFinish {
  /// Nothing.
  none,

  /// Stop the queue.
  stop,

  /// Suspend the computer.
  sleep,

  /// Power off.
  shutdown,

  /// Run a program.
  command,
}

/// The queue-level overrides the queue settings dialog edits. Everything else
/// in the queue's settings is carried over unchanged.
class QueueSettingsDraft {
  /// Creates a draft; the defaults are "no override".
  QueueSettingsDraft({
    this.speedLimit,
    WindowsDraft? schedule,
    this.scheduleOn = false,
    List<ProfileDraft>? profiles,
    this.quotaOn = false,
    this.quotaBytes,
    this.quotaPeriod,
    this.finish = QueueFinish.none,
    this.finishDelay,
    this.command = '',
    List<String>? args,
  }) : schedule = schedule ?? WindowsDraft(),
       profiles = profiles ?? [],
       args = args ?? [];

  /// Reads the overrides of [settings].
  factory QueueSettingsDraft.from(Settings settings) {
    final json = settings.toJson();
    final quota = json['quota'];
    final after = json['onQueueComplete'];
    final profileList = json['speedProfiles'];
    final sched = settings.schedule;
    return QueueSettingsDraft(
      speedLimit: settings.speedLimit,
      scheduleOn: sched != null,
      schedule: WindowsDraft.from(sched?.timezone, sched?.windows),
      profiles: [
        if (profileList is List)
          for (final p in profileList)
            if (p is Map<String, Object?>)
              ProfileDraft(
                windows: WindowsDraft.from(p['timezone'] as String?, [
                  for (final w in (p['windows'] as List? ?? const []))
                    TimeWindow.fromJson((w as Map).cast<String, Object?>()),
                ]),
                speedLimit: (p['speedLimit'] as num?)?.toInt() == 0
                    ? null
                    : (p['speedLimit'] as num?)?.toInt(),
              ),
      ],
      quotaOn: quota is Map,
      quotaBytes: quota is Map ? (quota['bytes'] as num?)?.toInt() : null,
      quotaPeriod: quota is Map ? parseGoDuration(quota['period']) : null,
      finish: after is Map
          ? QueueFinish.values.firstWhere(
              (f) => f.name == after['action'],
              orElse: () => QueueFinish.none,
            )
          : QueueFinish.none,
      finishDelay: after is Map ? parseGoDuration(after['delay']) : null,
      command: after is Map ? (after['command'] as String? ?? '') : '',
      args: after is Map
          ? [for (final a in (after['args'] as List? ?? const [])) '$a']
          : null,
    );
  }

  /// Own speed limit in bytes per second; null follows the global one.
  int? speedLimit;

  /// Whether the queue only runs in [schedule].
  bool scheduleOn;

  /// The weekly hours of the schedule.
  final WindowsDraft schedule;

  /// The speed profiles.
  final List<ProfileDraft> profiles;

  /// Whether a quota applies.
  bool quotaOn;

  /// Quota bytes per period.
  int? quotaBytes;

  /// Length of the quota period.
  Duration? quotaPeriod;

  /// What happens when the queue finishes.
  QueueFinish finish;

  /// Grace period before the action; null means the daemon's default.
  Duration? finishDelay;

  /// Program of [QueueFinish.command] (an absolute path).
  String command;

  /// Arguments of the program.
  final List<String> args;

  /// Whether the program path looks absolute (POSIX, drive or UNC).
  static bool isAbsolutePath(String path) =>
      path.startsWith('/') ||
      RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path) ||
      path.startsWith(r'\\');

  /// Whether the draft can be saved: what the daemon would reject is caught
  /// here so the dialog can say so before sending.
  bool get valid =>
      (!scheduleOn || !schedule.isEmpty) &&
      profiles.every((p) => !p.windows.isEmpty) &&
      (!quotaOn ||
          ((quotaBytes ?? 0) > 0 &&
              (quotaPeriod ?? Duration.zero) >= minQuotaPeriod)) &&
      (finishDelay == null || finishDelay! <= maxActionDelay) &&
      (finish != QueueFinish.command || isAbsolutePath(command.trim()));

  /// [base] with the edited overrides applied; the other settings stay as
  /// they were and a cleared override becomes unset again.
  Settings applyTo(Settings base) {
    final json = Map<String, Object?>.of(base.toJson());
    json['speedLimit'] = speedLimit;
    json['schedule'] = scheduleOn
        ? {
            if (schedule.timezone != null) 'timezone': schedule.timezone,
            'windows': [for (final w in schedule.toWindows()) w.toJson()],
          }
        : null;
    json['speedProfiles'] = profiles.isEmpty
        ? null
        : [
            for (final p in profiles)
              {
                if (p.windows.timezone != null) 'timezone': p.windows.timezone,
                'windows': [for (final w in p.windows.toWindows()) w.toJson()],
                'speedLimit': p.speedLimit ?? 0,
              },
          ];
    json['quota'] = quotaOn
        ? {'bytes': quotaBytes, 'period': goDuration(quotaPeriod!)}
        : null;
    json['onQueueComplete'] = finish == QueueFinish.none
        ? null
        : {
            'action': finish.name,
            if (finish == QueueFinish.command) ...{
              'command': command.trim(),
              if (args.isNotEmpty) 'args': args,
            },
            if (finishDelay != null) 'delay': goDuration(finishDelay!),
          };
    return Settings.fromJson(json);
  }
}
