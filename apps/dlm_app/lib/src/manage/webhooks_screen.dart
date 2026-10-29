import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../shell/feedback.dart';
import 'webhook_draft.dart';

/// The webhooks: addresses that are sent the daemon's events. Each can be
/// tested, switched off, and its recent deliveries read.
class WebhooksScreen extends ConsumerWidget {
  /// Creates the page.
  const WebhooksScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    Webhook? hook,
  }) async {
    final l = AppLocalizations.of(context);
    final draft = await showDlmDialog<WebhookDraft>(
      context,
      semanticLabel: hook == null ? l.wh_add_title : l.wh_edit_title,
      builder: (_) => WebhookDialog(hook: hook),
    );
    if (draft == null || !context.mounted) return;
    try {
      final controller = ref.read(webhooksProvider.notifier);
      if (hook == null) {
        await controller.create(draft.toCreate());
      } else {
        await controller.edit(hook.id, draft.toUpdate(hook));
      }
      if (context.mounted) showNotice(context, ref, l.wh_saved);
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _test(BuildContext context, WidgetRef ref, Webhook hook) async {
    final l = AppLocalizations.of(context);
    try {
      await ref.read(webhooksProvider.notifier).test(hook.id);
      if (context.mounted) showNotice(context, ref, l.wh_test_ok(hook.url));
    } on Object catch (e) {
      // The daemon answers 502 when the endpoint refuses the event.
      if (context.mounted) {
        showNotice(
          context,
          ref,
          l.wh_test_failed(hook.url),
          tone: DlmTone.danger,
        );
        showFailure(context, ref, e);
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Webhook hook,
  ) async {
    final l = AppLocalizations.of(context);
    final ok = await showDlmConfirm(
      context,
      title: l.wh_delete_title(hook.url),
      message: l.wh_delete_message,
      confirmLabel: l.wh_delete_confirm,
      cancelLabel: l.delete_cancel,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(webhooksProvider.notifier).remove(hook.id);
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    Webhook hook,
    bool enabled,
  ) async {
    try {
      await ref
          .read(webhooksProvider.notifier)
          .edit(hook.id, UpdateWebhookBody(enabled: enabled));
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final async = ref.watch(webhooksProvider);
    final list = async.value;
    if (list == null) {
      return async.hasError
          ? DlmErrorState(
              title: l.list_error_title,
              message: async.error.toString(),
              retryLabel: l.list_retry,
              onRetry: () => ref.invalidate(webhooksProvider),
            )
          : DlmLoadingState(label: l.list_loading);
    }
    final gap = theme.metrics.spacing.md;
    return Padding(
      padding: EdgeInsets.all(theme.metrics.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.wh_intro,
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          SizedBox(height: gap),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: DlmButton(
              label: l.wh_add,
              icon: const DlmIcon(DlmIconName.plus),
              variant: DlmButtonVariant.primary,
              onPressed: () => unawaited(_edit(context, ref)),
            ),
          ),
          SizedBox(height: gap),
          Expanded(
            child: list.isEmpty
                ? DlmEmptyState(
                    title: l.wh_empty_title,
                    message: l.wh_empty_message,
                  )
                : ListView(
                    children: [
                      for (final h in list)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: theme.metrics.spacing.xs,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colors.raised,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(theme.metrics.spacing.sm),
                              child: Row(
                                children: [
                                  DlmSwitch(
                                    value: h.enabled,
                                    semanticLabel: l.wh_enabled(h.url),
                                    onChanged: (v) =>
                                        unawaited(_toggle(context, ref, h, v)),
                                  ),
                                  SizedBox(width: theme.metrics.spacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          h.url,
                                          style: theme.typography.subtitle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          (h.events ?? const []).isEmpty
                                              ? l.wh_all_events
                                              : l.wh_events_count(
                                                  h.events!.length,
                                                ),
                                          style: theme.typography.caption
                                              .copyWith(
                                                color:
                                                    theme.colors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (h.hasSecret) DlmBadge(label: l.wh_signed),
                                  DlmButton(
                                    label: l.wh_test,
                                    variant: DlmButtonVariant.plain,
                                    onPressed: () =>
                                        unawaited(_test(context, ref, h)),
                                  ),
                                  DlmButton(
                                    label: l.wh_log,
                                    variant: DlmButtonVariant.plain,
                                    onPressed: () => unawaited(
                                      showDlmDialog<void>(
                                        context,
                                        semanticLabel: l.wh_log_title(h.url),
                                        builder: (_) =>
                                            DeliveriesDialog(hook: h),
                                      ),
                                    ),
                                  ),
                                  DlmIconButton(
                                    icon: const DlmIcon(DlmIconName.edit),
                                    semanticLabel: l.wh_edit(h.url),
                                    size: DlmControlSize.small,
                                    onPressed: () =>
                                        unawaited(_edit(context, ref, hook: h)),
                                  ),
                                  DlmIconButton(
                                    icon: const DlmIcon(DlmIconName.trash),
                                    semanticLabel: l.wh_delete(h.url),
                                    size: DlmControlSize.small,
                                    onPressed: () =>
                                        unawaited(_delete(context, ref, h)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// The add/edit dialog of a webhook; pops the [WebhookDraft].
class WebhookDialog extends StatefulWidget {
  /// Creates the dialog; [hook] is null for a new one.
  const WebhookDialog({this.hook, super.key});

  /// The webhook being edited.
  final Webhook? hook;

  @override
  State<WebhookDialog> createState() => _WebhookDialogState();
}

class _WebhookDialogState extends State<WebhookDialog> {
  late final WebhookDraft _draft = WebhookDraft(from: widget.hook);
  late final TextEditingController _url = TextEditingController(
    text: _draft.url,
  );
  final TextEditingController _secret = TextEditingController();

  @override
  void dispose() {
    _url.dispose();
    _secret.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final d = _draft;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DlmFormGroup(
          children: [
            DlmFormRow(
              label: l.wh_url,
              control: DlmTextField(
                controller: _url,
                semanticLabel: l.wh_url,
                placeholder: 'https://example.com/hook',
                errorText: d.url.isEmpty || d.urlValid
                    ? null
                    : l.wh_url_invalid,
                onChanged: (v) => setState(() => d.url = v),
              ),
            ),
            DlmFormRow(
              label: l.wh_secret,
              description: d.isNew ? l.wh_secret_desc : l.wh_secret_keep,
              control: DlmPasswordField(
                controller: _secret,
                semanticLabel: l.wh_secret,
                showLabel: l.field_show,
                hideLabel: l.field_hide,
                onChanged: (v) => setState(() => d.secret = v),
              ),
            ),
            if (d.hadSecret)
              DlmFormRow(
                label: l.wh_secret_remove,
                control: DlmSwitch(
                  value: d.removeSecret,
                  semanticLabel: l.wh_secret_remove,
                  onChanged: (v) => setState(() => d.removeSecret = v),
                ),
              ),
            DlmFormRow(
              label: l.wh_enabled_label,
              control: DlmSwitch(
                value: d.enabled,
                semanticLabel: l.wh_enabled_label,
                onChanged: (v) => setState(() => d.enabled = v),
              ),
            ),
          ],
        ),
        SizedBox(height: theme.metrics.spacing.md),
        Text(l.wh_events, style: theme.typography.subtitle),
        Text(
          l.wh_events_desc,
          style: theme.typography.caption.copyWith(
            color: theme.colors.textSecondary,
          ),
        ),
        SizedBox(height: theme.metrics.spacing.xs),
        for (final e in webhookEvents)
          DlmCheckbox(
            value: d.events.contains(e)
                ? DlmCheckState.checked
                : DlmCheckState.unchecked,
            label: e,
            onChanged: (v) => setState(() {
              if (v == DlmCheckState.checked) {
                d.events.add(e);
              } else {
                d.events.remove(e);
              }
            }),
          ),
      ],
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 560,
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: DlmDialogContent(
        title: widget.hook == null ? l.wh_add_title : l.wh_edit_title,
        child: Flexible(child: SingleChildScrollView(child: body)),
        actions: [
          DlmButton(
            label: l.files_cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
          DlmButton(
            label: l.queue_save,
            variant: DlmButtonVariant.primary,
            onPressed: d.valid ? () => Navigator.of(context).pop(d) : null,
          ),
        ],
      ),
    );
  }
}

/// The recent delivery attempts to a webhook (kept by the daemon since it
/// started; test deliveries are included).
class DeliveriesDialog extends ConsumerStatefulWidget {
  /// Creates the dialog for [hook].
  const DeliveriesDialog({required this.hook, super.key});

  /// The webhook.
  final Webhook hook;

  @override
  ConsumerState<DeliveriesDialog> createState() => _DeliveriesDialogState();
}

class _DeliveriesDialogState extends ConsumerState<DeliveriesDialog> {
  late Future<List<Delivery>> _future = _load();

  Future<List<Delivery>> _load() =>
      ref.read(webhooksProvider.notifier).deliveries(widget.hook.id);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final time = DateFormat.yMd(l.localeName).add_Hms();
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 640,
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: DlmDialogContent(
        title: l.wh_log_title(widget.hook.url),
        message: l.wh_log_desc,
        child: Flexible(
          child: FutureBuilder<List<Delivery>>(
            future: _future,
            builder: (context, snap) {
              if (snap.hasError) {
                return DlmBanner(tone: DlmTone.danger, message: l.wh_log_error);
              }
              final list = snap.data;
              if (list == null) return DlmLoadingState(label: l.list_loading);
              if (list.isEmpty) return DlmEmptyState(title: l.wh_log_empty);
              return ListView(
                shrinkWrap: true,
                children: [
                  for (final d in list)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: theme.metrics.spacing.xs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DlmIcon(
                            d.ok ? DlmIconName.success : DlmIconName.error,
                            color: d.ok
                                ? theme.colors.success
                                : theme.colors.danger,
                          ),
                          SizedBox(width: theme.metrics.spacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.event),
                                Text(
                                  [
                                    time.format(d.time.toLocal()),
                                    if (d.status == 0)
                                      l.wh_log_no_answer
                                    else
                                      l.wh_log_status(d.status),
                                    l.wh_log_attempt(d.attempt),
                                    '${d.durationMs} ms',
                                    if (d.willRetry) l.wh_log_retry,
                                  ].join(' · '),
                                  style: theme.typography.caption.copyWith(
                                    color: theme.colors.textSecondary,
                                  ),
                                ),
                                if (d.error != null && d.error!.isNotEmpty)
                                  Text(
                                    d.error!,
                                    style: theme.typography.caption.copyWith(
                                      color: theme.colors.danger,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        actions: [
          DlmButton(
            label: l.wh_log_refresh,
            onPressed: () => setState(() {
              _future = _load();
            }),
          ),
          DlmButton(
            label: l.add_close,
            variant: DlmButtonVariant.primary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
