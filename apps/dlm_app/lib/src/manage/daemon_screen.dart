import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/settings_form.dart' show humaniseSetting, isDuration;
import '../shell/feedback.dart';
import 'config_draft.dart';
import 'log_view.dart';
import 'servers_group.dart';

/// The boot configuration of the daemon.
final configProvider = FutureProvider.autoDispose<ConfigView>(
  (ref) => ref.watch(daemonRepositoryProvider).config(),
);

/// The daemon: its boot configuration (changes take effect after a restart,
/// which the page offers) and its log.
class DaemonScreen extends ConsumerStatefulWidget {
  /// Creates the page.
  const DaemonScreen({super.key});

  @override
  ConsumerState<DaemonScreen> createState() => _DaemonScreenState();
}

class _DaemonScreenState extends ConsumerState<DaemonScreen> {
  ConfigDraft? _draft;
  ConfigView? _from;
  bool _saving = false;
  Map<String, List<String>> _errors = const {};

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final draft = _draft!;
    setState(() => _saving = true);
    try {
      await ref.read(daemonRepositoryProvider).updateConfig(draft.patch);
      if (!mounted) return;
      _draft = null;
      _from = null;
      _errors = const {};
      ref.invalidate(configProvider);
      showNotice(context, ref, l.dm_saved);
    } on ApiProblem catch (e) {
      if (!mounted) return;
      if (e.status == 422) {
        setState(() => _errors = fieldErrorsOf(e));
      } else {
        showFailure(context, ref, e);
      }
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _restart() async {
    final l = AppLocalizations.of(context);
    final ok = await showDlmConfirm(
      context,
      title: l.dm_restart_title,
      message: l.dm_restart_message,
      confirmLabel: l.dm_restart_confirm,
      cancelLabel: l.delete_cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(daemonRepositoryProvider).restart();
      if (!mounted) return;
      showNotice(context, ref, l.dm_restarting);
      // The connection banner shows the reconnecting; the page reads the
      // configuration again once the daemon is back.
      ref.invalidate(configProvider);
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    }
  }

  Widget _control(AppLocalizations l, Entry e, ConfigDraft d) {
    final value = d.valueOf(e.key);
    void set(Object? v) => setState(() => d.set(e.key, v));
    final enabled = !e.readOnly;
    switch (e.type) {
      case 'bool':
        return DlmSwitch(
          value: value == true,
          semanticLabel: e.key,
          onChanged: enabled ? set : null,
        );
      case 'int':
        return SizedBox(
          width: 160,
          child: DlmNumberField(
            value: value is num ? value : null,
            invalidText: l.settings_invalid_number,
            semanticLabel: e.key,
            enabled: enabled,
            onChanged: (v) => set(v?.toInt()),
          ),
        );
      case 'list':
        return SizedBox(
          width: 320,
          child: DlmParsedField<String>(
            value: value is List ? value.join(', ') : '',
            allowEmpty: true,
            parse: (t) => t,
            format: (v) => v,
            invalidText: '',
            semanticLabel: e.key,
            enabled: enabled,
            onChanged: (t) => set([
              for (final part in (t ?? '').split(RegExp(r'[,\n]+')))
                if (part.trim().isNotEmpty) part.trim(),
            ]),
          ),
        );
      default:
        final duration = e.type == 'duration';
        return SizedBox(
          width: 260,
          child: DlmParsedField<String>(
            value: value is String ? value : '',
            allowEmpty: true,
            parse: (t) => duration && t.trim().isNotEmpty && !isDuration(t)
                ? null
                : t.trim(),
            format: (v) => v,
            invalidText: l.settings_invalid_duration,
            semanticLabel: e.key,
            enabled: enabled,
            onChanged: (t) => set(t ?? ''),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final async = ref.watch(configProvider);
    final view = async.value;
    if (view == null) {
      return async.hasError
          ? DlmErrorState(
              title: l.list_error_title,
              message: async.error.toString(),
              retryLabel: l.list_retry,
              onRetry: () => ref.invalidate(configProvider),
            )
          : DlmLoadingState(label: l.list_loading);
    }
    if (_draft == null || !identical(_from, view)) {
      _from = view;
      _draft = ConfigDraft(view);
    }
    final d = _draft!;
    final groups = <String, List<Entry>>{};
    for (final e in view.entries ?? const <Entry>[]) {
      groups.putIfAbsent(e.key.split('.').first, () => []).add(e);
    }
    final gap = theme.metrics.spacing.lg;
    final caption = theme.typography.caption.copyWith(
      color: theme.colors.textSecondary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(theme.metrics.spacing.lg),
            children: [
              Text(
                l.dm_intro,
                style: theme.typography.body.copyWith(
                  color: theme.colors.textSecondary,
                ),
              ),
              SizedBox(height: theme.metrics.spacing.xs),
              Text(l.dm_file(view.file), style: caption),
              if (view.fileError != null)
                Padding(
                  padding: EdgeInsets.only(top: theme.metrics.spacing.xs),
                  child: DlmBanner(
                    tone: DlmTone.danger,
                    message: l.dm_file_error(view.fileError!),
                  ),
                ),
              if (view.restartPending)
                Padding(
                  padding: EdgeInsets.only(top: theme.metrics.spacing.sm),
                  child: DlmBanner(
                    tone: DlmTone.warning,
                    title: l.dm_pending_title,
                    message: l.dm_pending_message,
                    actionLabel: l.dm_restart_now,
                    onAction: () => unawaited(_restart()),
                  ),
                ),
              SizedBox(height: gap),
              for (final unmatched in [
                for (final e in _errors.entries)
                  if (!(view.entries ?? const <Entry>[]).any(
                    (x) => x.key == e.key,
                  ))
                    ...e.value,
              ])
                DlmBanner(tone: DlmTone.danger, message: unmatched),
              for (final g in groups.entries)
                Padding(
                  padding: EdgeInsets.only(bottom: gap),
                  child: DlmFormGroup(
                    title: humaniseSetting(g.key),
                    children: [
                      for (final e in g.value)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DlmFormRow(
                              label: e.key,
                              description: [
                                if (e.pending != null && !d.isEdited(e.key))
                                  l.dm_pending_value('${e.pending}'),
                                if (e.readOnly) l.dm_read_only,
                              ].join(' · '),
                              control: Wrap(
                                spacing: theme.metrics.spacing.sm,
                                runSpacing: theme.metrics.spacing.xs,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _control(l, e, d),
                                  DlmBadge(
                                    label: e.source,
                                    tone: e.source == 'default'
                                        ? DlmTone.neutral
                                        : DlmTone.accent,
                                  ),
                                  if (e.restartRequired)
                                    DlmBadge(
                                      label: l.settings_restart,
                                      tone: DlmTone.warning,
                                    ),
                                ],
                              ),
                            ),
                            for (final m in _errors[e.key] ?? const <String>[])
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: theme.metrics.spacing.md,
                                ),
                                child: Text(
                                  m,
                                  style: caption.copyWith(
                                    color: theme.colors.danger,
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              Text(l.dm_log_title, style: theme.typography.subtitle),
              SizedBox(height: theme.metrics.spacing.xs),
              SizedBox(
                height: 320,
                child: LogView(
                  load: ({level, q}) => ref
                      .read(daemonRepositoryProvider)
                      .logs(level: level, q: q),
                ),
              ),
              SizedBox(height: gap),
              const ServersGroup(),
            ],
          ),
        ),
        ColoredBox(
          color: theme.colors.raised,
          child: Padding(
            padding: EdgeInsets.all(theme.metrics.spacing.md),
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: theme.metrics.spacing.sm,
              children: [
                if (d.isDirty && d.editsNeedRestart)
                  Text(l.dm_needs_restart, style: caption),
                DlmButton(
                  label: l.settings_revert,
                  onPressed: d.isDirty && !_saving
                      ? () => setState(() {
                          d.revert();
                          _errors = const {};
                        })
                      : null,
                ),
                DlmButton(
                  label: l.settings_save,
                  variant: DlmButtonVariant.primary,
                  onPressed: d.isDirty && !_saving
                      ? () => unawaited(_save())
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
