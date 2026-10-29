import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../prefs/pref_providers.dart';
import 'feedback.dart';
import 'shell_state.dart';

/// What the failed items of a bulk action say: one toast naming how many.
void _reportPartial(
  BuildContext context,
  WidgetRef ref,
  List<ItemResult> results,
) {
  final failed = results.where((r) => !r.ok).toList();
  if (failed.isEmpty) return;
  final l = AppLocalizations.of(context);
  final first = failed.first.error;
  if (failed.length == 1 && first != null) {
    showFailure(context, ref, first);
    return;
  }
  showNotice(
    context,
    ref,
    l.toast_some_failed(failed.length),
    tone: DlmTone.danger,
  );
}

/// Pauses [ids]; offers Undo.
Future<void> pauseTasks(
  BuildContext context,
  WidgetRef ref,
  List<String> ids,
) async {
  final l = AppLocalizations.of(context);
  try {
    final results = await ref.read(taskActionsProvider).pause(ids);
    if (!context.mounted) return;
    final done = [
      for (final r in results)
        if (r.ok) r.id,
    ];
    _reportPartial(context, ref, results);
    if (done.isNotEmpty) {
      showNotice(
        context,
        ref,
        l.toast_paused(done.length),
        onUndo: () => resumeTasks(context, ref, done, undoable: false),
      );
    }
  } on Object catch (e) {
    if (context.mounted) showFailure(context, ref, e);
  }
}

/// Resumes [ids]; offers Undo unless this is already an undo.
Future<void> resumeTasks(
  BuildContext context,
  WidgetRef ref,
  List<String> ids, {
  bool undoable = true,
}) async {
  final l = AppLocalizations.of(context);
  try {
    final results = await ref.read(taskActionsProvider).resume(ids);
    if (!context.mounted) return;
    final done = [
      for (final r in results)
        if (r.ok) r.id,
    ];
    _reportPartial(context, ref, results);
    if (done.isNotEmpty && undoable) {
      showNotice(
        context,
        ref,
        l.toast_resumed(done.length),
        onUndo: () => pauseTasks(context, ref, done),
      );
    }
  } on Object catch (e) {
    if (context.mounted) showFailure(context, ref, e);
  }
}

/// Downloads a finished or failed task again from scratch.
Future<void> restartTask(BuildContext context, WidgetRef ref, String id) async {
  final l = AppLocalizations.of(context);
  try {
    await ref.read(taskActionsProvider).restart(id);
    if (context.mounted) showNotice(context, ref, l.toast_restarted);
  } on Object catch (e) {
    if (context.mounted) showFailure(context, ref, e);
  }
}

/// Asks, then deletes [ids]. A removed download cannot be restored, so there
/// is no Undo: the confirmation (which can be switched off in the preferences)
/// is the safeguard, and the default keeps the files on disk.
Future<void> deleteTasks(
  BuildContext context,
  WidgetRef ref,
  List<String> ids,
) async {
  final l = AppLocalizations.of(context);
  var files = false;
  if (ref.read(confirmDeleteProvider)) {
    final choice = await showDlmDialog<({bool files})>(
      context,
      semanticLabel: l.delete_title(ids.length),
      builder: (dialogContext) => _DeleteDialog(count: ids.length),
    );
    if (choice == null || !context.mounted) return;
    files = choice.files;
  }
  try {
    final results = await ref
        .read(taskActionsProvider)
        .delete(ids, files: files);
    if (!context.mounted) return;
    final done = results.where((r) => r.ok).length;
    ref.read(selectionProvider.notifier).set({
      for (final id in ref.read(selectionProvider))
        if (results.any((r) => r.id == id && !r.ok)) id,
    });
    _reportPartial(context, ref, results);
    if (done > 0) showNotice(context, ref, l.toast_deleted(done));
  } on Object catch (e) {
    if (context.mounted) showFailure(context, ref, e);
  }
}

/// Copies the link of [task] to the clipboard.
Future<void> copyLink(BuildContext context, WidgetRef ref, Task task) async {
  final l = AppLocalizations.of(context);
  await Clipboard.setData(ClipboardData(text: task.source.currentUrl));
  if (context.mounted) showNotice(context, ref, l.toast_link_copied);
}

class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog({required this.count});

  final int count;

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  bool _files = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DlmDialogContent(
      title: l.delete_title(widget.count),
      message: l.delete_message,
      child: DlmCheckbox(
        value: _files ? DlmCheckState.checked : DlmCheckState.unchecked,
        label: l.delete_files,
        onChanged: (v) => setState(() => _files = v == DlmCheckState.checked),
      ),
      actions: [
        DlmButton(
          label: l.delete_cancel,
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DlmButton(
          label: l.delete_confirm,
          variant: DlmButtonVariant.destructive,
          onPressed: () => Navigator.of(context).pop((files: _files)),
        ),
      ],
    );
  }
}

/// The context menu of the task the pointer is on: acts on the whole selection
/// when the task is part of it, otherwise on the task alone.
List<DlmMenuEntry> taskMenuEntries(
  BuildContext context,
  WidgetRef ref,
  Task clicked,
) {
  final l = AppLocalizations.of(context);
  final selection = ref.read(selectionProvider);
  final targets = selection.contains(clicked.id) && selection.length > 1
      ? [
          for (final id in selection)
            if (ref.read(taskProvider(id)) case final Task t) t,
        ]
      : [clicked];
  final ids = [for (final t in targets) t.id];
  final single = targets.length == 1;
  return [
    if (targets.any((t) => t.statusKind.canPause))
      DlmMenuItem(
        label: l.action_pause,
        icon: const DlmIcon(DlmIconName.pause),
        onPressed: () => pauseTasks(context, ref, ids),
      ),
    if (targets.any((t) => t.statusKind.canResume))
      DlmMenuItem(
        label: l.action_resume,
        icon: const DlmIcon(DlmIconName.play),
        onPressed: () => resumeTasks(context, ref, ids),
      ),
    if (single && clicked.statusKind.isFinished)
      DlmMenuItem(
        label: l.action_restart,
        icon: const DlmIcon(DlmIconName.restart),
        onPressed: () => restartTask(context, ref, clicked.id),
      ),
    if (single) ...[
      const DlmMenuSeparator(),
      DlmMenuItem(
        label: l.action_copy_link,
        icon: const DlmIcon(DlmIconName.copy),
        onPressed: () => copyLink(context, ref, clicked),
      ),
    ],
    const DlmMenuSeparator(),
    DlmMenuItem(
      label: l.action_delete,
      icon: const DlmIcon(DlmIconName.trash),
      destructive: true,
      onPressed: () => deleteTasks(context, ref, ids),
    ),
  ];
}
