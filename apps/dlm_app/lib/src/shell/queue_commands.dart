import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_routes.dart';
import 'feedback.dart';

/// Asks for a name, then creates a queue and opens it.
Future<void> createQueue(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final name = await _askName(
    context,
    title: l.queue_new_title,
    confirmLabel: l.queue_create,
  );
  if (name == null || !context.mounted) return;
  try {
    final queue = await ref
        .read(queuesProvider.notifier)
        .create(CreateQueueBody(name: name));
    if (!context.mounted) return;
    showNotice(context, ref, l.toast_queue_created(queue.name));
    context.go(queuePath(queue.id));
  } on Object catch (e) {
    if (context.mounted) showFailure(context, ref, e);
  }
}

/// Asks for a new name for [queue] and applies it.
Future<void> renameQueue(
  BuildContext context,
  WidgetRef ref,
  Queue queue,
) async {
  final l = AppLocalizations.of(context);
  final name = await _askName(
    context,
    title: l.queue_rename_title,
    confirmLabel: l.queue_save,
    initial: queue.name,
  );
  if (name == null || name == queue.name || !context.mounted) return;
  try {
    final renamed = await ref
        .read(queuesProvider.notifier)
        .edit(queue.id, UpdateQueueBody(name: name));
    if (context.mounted) {
      showNotice(context, ref, l.toast_queue_renamed(renamed.name));
    }
  } on Object catch (e) {
    if (context.mounted) showFailure(context, ref, e);
  }
}

/// Confirms, then deletes [queue]; its downloads go to the default queue.
Future<void> deleteQueue(
  BuildContext context,
  WidgetRef ref,
  Queue queue,
) async {
  final l = AppLocalizations.of(context);
  final confirmed = await showDlmConfirm(
    context,
    title: l.queue_delete_title(queue.name),
    message: l.queue_delete_message,
    confirmLabel: l.queue_delete_confirm,
    cancelLabel: l.delete_cancel,
    destructive: true,
  );
  if (!confirmed || !context.mounted) return;
  final defaultId = (ref.read(queuesProvider).value ?? const <Queue>[])
      .where((q) => q.isDefault)
      .firstOrNull
      ?.id;
  try {
    await ref
        .read(queuesProvider.notifier)
        .remove(queue.id, moveTasksTo: defaultId);
    if (!context.mounted) return;
    showNotice(context, ref, l.toast_queue_deleted(queue.name));
    context.go(homePath);
  } on Object catch (e) {
    if (context.mounted) showFailure(context, ref, e);
  }
}

/// Starts or stops [queue].
Future<void> setQueueRunning(
  BuildContext context,
  WidgetRef ref,
  Queue queue, {
  required bool running,
}) async {
  final l = AppLocalizations.of(context);
  final controller = ref.read(queuesProvider.notifier);
  try {
    if (running) {
      await controller.start(queue.id);
    } else {
      await controller.stop(queue.id);
    }
    if (!context.mounted) return;
    showNotice(
      context,
      ref,
      running
          ? l.toast_queue_started(queue.name)
          : l.toast_queue_stopped(queue.name),
    );
  } on Object catch (e) {
    if (context.mounted) showFailure(context, ref, e);
  }
}

/// Moves [queue] one place up (`-1`) or down (`1`) in the list.
Future<void> moveQueue(
  BuildContext context,
  WidgetRef ref,
  Queue queue,
  int offset,
) async {
  final queues = ref.read(queuesProvider).value ?? const <Queue>[];
  final index = queues.indexWhere((q) => q.id == queue.id);
  final target = index + offset;
  if (index < 0 || target < 0 || target >= queues.length) return;
  try {
    await ref
        .read(queuesProvider.notifier)
        .reorder(queue.id, queues[target].position);
  } on Object catch (e) {
    if (context.mounted) showFailure(context, ref, e);
  }
}

Future<String?> _askName(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String initial = '',
}) => showDlmDialog<String>(
  context,
  semanticLabel: title,
  builder: (_) =>
      _NameDialog(title: title, confirmLabel: confirmLabel, initial: initial),
);

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.confirmLabel,
    required this.initial,
  });

  final String title;
  final String confirmLabel;
  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _name.text.trim();
    if (text.isNotEmpty) Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DlmDialogContent(
      title: widget.title,
      child: ListenableBuilder(
        listenable: _name,
        builder: (context, _) => DlmTextField(
          controller: _name,
          autofocus: true,
          semanticLabel: l.queue_name_label,
          placeholder: l.queue_name_placeholder,
          onSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        DlmButton(
          label: l.qs_cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        ListenableBuilder(
          listenable: _name,
          builder: (context, _) => DlmButton(
            label: widget.confirmLabel,
            variant: DlmButtonVariant.primary,
            onPressed: _name.text.trim().isEmpty ? null : _submit,
          ),
        ),
      ],
    );
  }
}
