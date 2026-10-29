import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task_format.dart';

/// The title of a task for assistive technology and the name column.
String taskTitleOf(AppLocalizations l, Task t) => taskTitle(l, t);

/// The status text of a task.
String statusLabelOf(AppLocalizations l, Task t) =>
    statusLabel(l, t.statusKind);

/// A widget that rebuilds only when the task [id] changes in the store, so a
/// progress tick repaints one card.
class TaskCell extends ConsumerWidget {
  /// Creates a widget showing what [builder] makes of the live task.
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

/// The name of the first category whose extensions list that of [fileName], or
/// null. Rules on MIME type or URL are the daemon's to apply, so a download
/// they would catch shows no category here.
String? categoryOfFile(List<Category> categories, String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot < 0 || dot == fileName.length - 1) return null;
  final ext = fileName.substring(dot + 1).toLowerCase();
  for (final c in categories) {
    for (final e in c.extensions ?? const <String>[]) {
      if (e.toLowerCase().replaceFirst('.', '') == ext) return c.name;
    }
  }
  return null;
}
