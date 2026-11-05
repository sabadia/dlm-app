import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:intl/intl.dart';

/// The localised name of a task status.
String statusLabel(AppLocalizations l, TaskStatus s) => switch (s) {
  TaskStatus.queued => l.task_status_queued,
  TaskStatus.running => l.task_status_running,
  TaskStatus.paused => l.task_status_paused,
  TaskStatus.awaitingLink => l.task_status_awaiting_link,
  TaskStatus.refreshing => l.task_status_refreshing,
  TaskStatus.postprocessing => l.task_status_postprocessing,
  TaskStatus.completed => l.task_status_completed,
  TaskStatus.error => l.task_status_error,
  TaskStatus.unknown => l.task_status_unknown,
};

/// The colour meaning of a task status.
DlmTone statusTone(TaskStatus s) => switch (s) {
  TaskStatus.completed => DlmTone.success,
  TaskStatus.error => DlmTone.danger,
  TaskStatus.running ||
  TaskStatus.refreshing ||
  TaskStatus.postprocessing => DlmTone.accent,
  TaskStatus.awaitingLink => DlmTone.warning,
  TaskStatus.queued ||
  TaskStatus.paused ||
  TaskStatus.unknown => DlmTone.neutral,
};

/// The name to show for [task]: its name, else the last part of its source
/// URL, else a generic label.
String taskTitle(AppLocalizations l, Task task) {
  final name = task.name;
  if (name != null && name.trim().isNotEmpty) return name;
  final uri = Uri.tryParse(task.source.currentUrl);
  final last = uri?.pathSegments.where((s) => s.isNotEmpty).lastOrNull;
  if (last != null && last.isNotEmpty) return Uri.decodeComponent(last);
  return l.task_unnamed;
}

/// "3 minutes ago" or a date.
String addedText(AppLocalizations l, DateTime when, DateTime now) {
  final r = relativeTime(when, now);
  return relativeTimeText(
    l,
    kind: r.kind.name,
    count: r.count,
    date: () => DateFormat.yMMMd(l.localeName).format(when.toLocal()),
  );
}

/// The status as shown for [t]: a failed task that the daemon will start again
/// is "Retrying", a torrent that only serves its data is "Seeding".
String statusLabelFor(AppLocalizations l, Task t) {
  if (t.isWaitingForRetry) return l.task_status_retrying;
  if (t.isSeeding) return l.task_status_seeding;
  return statusLabel(l, t.statusKind);
}

/// The colour of [statusLabelFor].
DlmTone statusToneFor(Task t) {
  if (t.isWaitingForRetry) return DlmTone.warning;
  if (t.isSeeding) return DlmTone.success;
  return statusTone(t.statusKind);
}

/// A short, readable reason a task failed (the raw error is nested engine text
/// with addresses in it); null when the task has not failed.
String? failureReason(AppLocalizations l, Task t) {
  final e = t.error;
  if (t.statusKind != TaskStatus.error || e == null) return null;
  return switch (e.code) {
    'network' => l.task_reason_network,
    'link_expired' => l.task_reason_link_expired,
    'disk_full' => l.task_reason_disk_full,
    'http_status' => l.task_reason_http,
    'checksum_mismatch' => l.task_reason_checksum,
    'postprocess' => l.task_reason_postprocess,
    'infected' => l.task_reason_infected,
    _ => _firstLine(e.message),
  };
}

String _firstLine(String message) {
  var text = message.split('\n').first.trim();
  // The engine nests its context ("retry: giving up after 6 attempts: engine:
  // fatal: ...") before the part a person can use.
  for (final prefix in const ['retry: ', 'engine: ']) {
    while (text.startsWith(prefix)) {
      text = text.substring(prefix.length);
    }
  }
  return text.length > 90 ? '${text.substring(0, 89)}…' : text;
}

/// "Retry 2 of 3 in 40 s" for a task waiting for its automatic retry, else null.
String? retryNote(AppLocalizations l, Task t, {DateTime? now}) {
  final retry = t.error?.retry;
  if (!t.isWaitingForRetry || retry == null) return null;
  final left = retry.nextAt.difference(now ?? DateTime.now());
  if (left <= Duration.zero) {
    return l.task_retry_soon(retry.attempt, retry.max);
  }
  return l.task_retry_in(retry.attempt, retry.max, formatDuration(left));
}
