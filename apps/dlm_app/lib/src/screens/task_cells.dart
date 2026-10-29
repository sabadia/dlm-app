import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_format.dart';

/// The title of a task for assistive technology and the name column.
String taskTitleOf(AppLocalizations l, Task t) => taskTitle(l, t);

/// The status text of a task.
String statusLabelOf(AppLocalizations l, Task t) =>
    statusLabel(l, t.statusKind);

/// A table cell that rebuilds only when the task [id] changes in the store,
/// so a progress tick repaints one row.
class TaskCell extends ConsumerWidget {
  /// Creates a cell showing what [builder] makes of the live task.
  const TaskCell({required this.id, required this.builder, super.key});

  /// The task.
  final String id;

  /// Builds the cell from the live task; [progress] is null when the daemon
  /// has sent none.
  final Widget Function(BuildContext context, Task task, ProgressData? progress)
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskProvider(id));
    if (task == null) return const SizedBox.shrink();
    final progress = ref.watch(taskProgressProvider(id));
    return builder(context, task, progress);
  }
}

/// The columns of the downloads table.
List<DlmColumn<Task>> taskColumns(AppLocalizations l) => [
  DlmColumn<Task>(
    id: 'name',
    label: l.col_name,
    sortable: true,
    width: 280,
    minWidth: 140,
    cell: (context, t) => TaskCell(
      id: t.id,
      builder: (context, task, _) => Text(
        taskTitle(l, task),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ),
  DlmColumn<Task>(
    id: 'status',
    label: l.col_status,
    width: 130,
    cell: (context, t) => TaskCell(
      id: t.id,
      builder: (context, task, _) => DlmBadge(
        label: statusLabel(l, task.statusKind),
        tone: statusTone(task.statusKind),
      ),
    ),
  ),
  DlmColumn<Task>(
    id: 'progress',
    label: l.col_progress,
    width: 170,
    cell: (context, t) => TaskCell(
      id: t.id,
      builder: (context, task, progress) {
        final downloaded = progress?.downloaded ?? task.downloaded;
        final size = progress?.size ?? task.size;
        final fraction = size > 0 ? (downloaded / size).clamp(0.0, 1.0) : null;
        final finished = task.statusKind == TaskStatus.completed;
        return Row(
          children: [
            Expanded(
              child: DlmProgressBar(
                value: finished ? 1 : fraction,
                tone: switch (task.statusKind) {
                  TaskStatus.completed => DlmTone.success,
                  TaskStatus.error => DlmTone.danger,
                  _ => DlmTone.accent,
                },
                semanticLabel: taskTitle(l, task),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 38,
              child: Text(
                fraction == null && !finished
                    ? ''
                    : '${((finished ? 1 : fraction!) * 100).floor()}%',
                textAlign: TextAlign.end,
              ),
            ),
          ],
        );
      },
    ),
  ),
  DlmColumn<Task>(
    id: 'size',
    label: l.col_size,
    sortable: true,
    width: 100,
    alignment: AlignmentDirectional.centerEnd,
    cell: (context, t) => TaskCell(
      id: t.id,
      builder: (context, task, progress) =>
          Text(formatBytes(progress?.size ?? task.size) ?? ''),
    ),
  ),
  DlmColumn<Task>(
    id: 'speed',
    label: l.col_speed,
    width: 110,
    alignment: AlignmentDirectional.centerEnd,
    cell: (context, t) => TaskCell(
      id: t.id,
      builder: (context, task, progress) => Text(
        task.statusKind.isActive && progress != null && progress.speed > 0
            ? formatSpeed(progress.speed) ?? ''
            : '',
      ),
    ),
  ),
  DlmColumn<Task>(
    id: 'eta',
    label: l.col_eta,
    width: 110,
    alignment: AlignmentDirectional.centerEnd,
    cell: (context, t) => TaskCell(
      id: t.id,
      builder: (context, task, progress) {
        if (!task.statusKind.isActive || progress == null) {
          return const SizedBox.shrink();
        }
        final left = estimateRemaining(
          downloaded: progress.downloaded,
          size: progress.size,
          bytesPerSecond: progress.speed,
        );
        return Text(left == null ? '' : formatDuration(left));
      },
    ),
  ),
  DlmColumn<Task>(
    id: 'queue',
    label: l.col_queue,
    width: 130,
    cell: (context, t) => TaskCell(
      id: t.id,
      builder: (context, task, _) => _QueueName(id: task.queueId),
    ),
  ),
  DlmColumn<Task>(
    id: 'added',
    label: l.col_added,
    sortable: true,
    cell: (context, t) => TaskCell(
      id: t.id,
      builder: (context, task, _) =>
          Text(addedText(l, task.createdAt, DateTime.now())),
    ),
  ),
  DlmColumn<Task>(
    id: 'engine',
    label: l.col_engine,
    width: 90,
    cell: (context, t) => TaskCell(
      id: t.id,
      builder: (context, task, _) =>
          Text(task.engine ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
  ),
];

class _QueueName extends ConsumerWidget {
  const _QueueName({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(queueProvider(id))?.name;
    return Text(name ?? id, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}
