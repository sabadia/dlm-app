import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../shell/feedback.dart';

/// The link of a download: where it comes from, buttons to renew or replace
/// it, and the attempts made to renew it before.
class SourceTab extends ConsumerWidget {
  /// Creates the tab for the task [id].
  const SourceTab({required this.id, super.key});

  /// The task.
  final String id;

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<Task> Function(RefreshRepository repo) call,
    String done,
  ) async {
    try {
      final task = await call(ref.read(refreshRepositoryProvider));
      ref.read(taskStoreProvider).tasks.put(task.id, task);
      ref.invalidate(taskRefreshesProvider(id));
      if (context.mounted) showNotice(context, ref, done);
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final task = ref.watch(taskProvider(id));
    if (task == null) return const SizedBox.shrink();
    // A renewal ends with a status change, and then the history has a new
    // entry.
    ref.listen(taskProvider(id), (before, after) {
      if (before?.status != after?.status) {
        ref.invalidate(taskRefreshesProvider(id));
      }
    });
    final source = task.source;
    final paused = task.statusKind == TaskStatus.paused;
    final attempts = ref.watch(taskRefreshesProvider(id));
    String when(DateTime t) =>
        DateFormat.yMMMd(l.localeName).add_Hm().format(t.toLocal());

    Widget link(String label, String? value, {bool copy = false}) =>
        value == null || value.isEmpty
        ? const SizedBox.shrink()
        : DlmFormRow(
            label: label,
            control: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(value, textAlign: TextAlign.end)),
                if (copy)
                  DlmIconButton(
                    icon: const DlmIcon(DlmIconName.copy),
                    semanticLabel: l.src_copy,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: value));
                      if (context.mounted) {
                        showNotice(context, ref, l.toast_link_copied);
                      }
                    },
                  ),
              ],
            ),
          );

    return ListView(
      padding: EdgeInsets.all(theme.metrics.spacing.md),
      children: [
        DlmFormGroup(
          title: l.src_group_link,
          children: [
            link(l.src_current, source.currentUrl, copy: true),
            if (source.originalUrl != source.currentUrl)
              link(l.src_original, source.originalUrl),
            link(l.src_page, source.pageUrl),
            link(l.src_referrer, source.referrer),
            if (source.mirrors != null && source.mirrors!.isNotEmpty)
              link(l.src_mirrors, source.mirrors!.join('\n')),
          ],
        ),
        SizedBox(height: theme.metrics.spacing.md),
        Wrap(
          spacing: theme.metrics.spacing.sm,
          runSpacing: theme.metrics.spacing.sm,
          children: [
            DlmButton(
              label: l.src_refresh,
              icon: const DlmIcon(DlmIconName.refresh),
              onPressed: () => unawaited(
                _run(
                  context,
                  ref,
                  (r) => r.refresh(id),
                  l.toast_link_refreshing,
                ),
              ),
            ),
            DlmButton(
              label: l.src_await,
              onPressed: () => unawaited(
                _run(
                  context,
                  ref,
                  (r) => r.awaitLink(id),
                  l.toast_link_waiting,
                ),
              ),
            ),
            DlmButton(
              label: l.src_edit,
              icon: const DlmIcon(DlmIconName.edit),
              onPressed: paused
                  ? () => unawaited(_replace(context, ref, source.currentUrl))
                  : null,
            ),
          ],
        ),
        if (!paused)
          Padding(
            padding: EdgeInsets.only(top: theme.metrics.spacing.xs),
            child: Text(
              l.src_edit_needs_pause,
              style: theme.typography.caption.copyWith(
                color: theme.colors.textSecondary,
              ),
            ),
          ),
        SizedBox(height: theme.metrics.spacing.lg),
        DlmFormGroup(
          title: l.src_group_history,
          children: [
            ...attempts.when(
              data: (list) => list.isEmpty
                  ? [
                      DlmFormRow(
                        label: l.src_history_empty,
                        control: const SizedBox(),
                      ),
                    ]
                  : [
                      for (final a in list)
                        DlmFormRow(
                          label: l.src_attempt(a.strategy, a.outcome),
                          description: [
                            when(a.createdAt),
                            l.src_attempt_cause(a.cause),
                            ?a.error,
                          ].join('\n'),
                          control: const SizedBox(),
                        ),
                    ],
              loading: () => [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: DlmProgressRing(value: null, size: 18),
                ),
              ],
              error: (e, _) => [
                DlmFormRow(label: e.toString(), control: const SizedBox()),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _replace(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l = AppLocalizations.of(context);
    final url = await showDlmDialog<String>(
      context,
      semanticLabel: l.src_edit_title,
      builder: (_) => _ReplaceLinkDialog(current: current),
    );
    if (url == null || url == current || !context.mounted) return;
    await _run(
      context,
      ref,
      (r) => r.setLink(
        id,
        url,
        onMismatch: UpdateTaskSourceBodyOnMismatch.restart,
      ),
      l.toast_link_replaced,
    );
  }
}

class _ReplaceLinkDialog extends StatefulWidget {
  const _ReplaceLinkDialog({required this.current});

  final String current;

  @override
  State<_ReplaceLinkDialog> createState() => _ReplaceLinkDialogState();
}

class _ReplaceLinkDialogState extends State<_ReplaceLinkDialog> {
  late final TextEditingController _url = TextEditingController(
    text: widget.current,
  );

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  bool get _valid {
    final uri = Uri.tryParse(_url.text.trim());
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  void _submit() {
    if (_valid) Navigator.of(context).pop(_url.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DlmDialogContent(
      title: l.src_edit_title,
      message: l.src_edit_hint,
      child: DlmTextField(
        controller: _url,
        autofocus: true,
        semanticLabel: l.src_edit_label,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        DlmButton(
          label: l.qs_cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DlmButton(
          label: l.src_edit_save,
          variant: DlmButtonVariant.primary,
          onPressed: _valid ? _submit : null,
        ),
      ],
    );
  }
}
