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
