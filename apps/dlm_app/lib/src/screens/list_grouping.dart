import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';

import 'list_views.dart';
import 'task_format.dart';

/// Id prefix of the synthetic heading rows of a grouped list.
const String groupHeaderPrefix = 'header:';

/// Whether [row] is a heading made by [groupRows], not a download.
bool isGroupHeaderRow(Task row) => row.id.startsWith(groupHeaderPrefix);

/// The rows of [tasks] under one heading per group, in the order the groups
/// first appear; a heading is a placeholder [Task] whose name is the group
/// label and whose size is the count of downloads under it.
///
/// Only the downloads that are loaded are grouped, so a later page can add to
/// a group that is already shown.
List<Task> groupRows(
  AppLocalizations l,
  List<Task> tasks,
  ListGrouping grouping, {
  required Map<String, String> queueNames,
}) {
  if (grouping == ListGrouping.none) return tasks;
  String keyOf(Task t) => switch (grouping) {
    ListGrouping.status => statusLabel(l, t.statusKind),
    ListGrouping.queue => queueNames[t.queueId] ?? t.queueId,
    ListGrouping.engine => t.engine ?? '—',
    ListGrouping.none => '',
  };
  final groups = <String, List<Task>>{};
  for (final t in tasks) {
    (groups[keyOf(t)] ??= []).add(t);
  }
  return [
    for (final e in groups.entries) ...[
      Task(
        createdAt: e.value.first.createdAt,
        downloaded: 0,
        id: '$groupHeaderPrefix${e.key}',
        position: 0,
        priority: 'normal',
        queueId: '',
        settings: const Settings(),
        size: e.value.length,
        source: const Source(
          currentUrl: '',
          fingerprint: Fingerprint(size: -1),
        ),
        status: 'queued',
        updatedAt: e.value.first.updatedAt,
        name: e.key,
      ),
      ...e.value,
    ],
  ];
}
