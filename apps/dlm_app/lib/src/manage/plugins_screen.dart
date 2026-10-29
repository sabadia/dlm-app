import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../add/folder_browser.dart';
import '../shell/feedback.dart';
import 'log_view.dart';

/// The plugins: JavaScript extensions that run inside the daemon. A plugin is
/// installed switched off; the user reviews what it may do (the events it
/// reacts to and the hosts it may contact) before switching it on.
class PluginsScreen extends ConsumerWidget {
  /// Creates the page.
  const PluginsScreen({super.key});

  Future<void> _install(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final draft = await showDlmDialog<InstallDraft>(
      context,
      semanticLabel: l.pl_install_title,
      builder: (_) => const InstallPluginDialog(),
    );
    if (draft == null || !context.mounted) return;
    try {
      // Installed off, so nothing runs before the review.
      final plugin = await ref
          .read(pluginsProvider.notifier)
          .install(
            InstallPluginBody(
              source: draft.source.trim(),
              ref: draft.ref.trim().isEmpty ? null : draft.ref.trim(),
              replace: draft.replace ? true : null,
              disabled: true,
            ),
          );
      if (!context.mounted) return;
      await _review(context, ref, plugin, fresh: true);
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _review(
    BuildContext context,
    WidgetRef ref,
    Plugin plugin, {
    required bool fresh,
  }) async {
    final l = AppLocalizations.of(context);
    final enable = await showDlmDialog<bool>(
      context,
      semanticLabel: l.pl_review_title(plugin.title ?? plugin.name),
      builder: (_) => PluginReviewDialog(plugin: plugin, fresh: fresh),
    );
    if (enable != true || !context.mounted) return;
    try {
      await ref
          .read(pluginsProvider.notifier)
          .setEnabled(plugin.name, enabled: true);
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    Plugin plugin,
  ) async {
    final l = AppLocalizations.of(context);
    final ok = await showDlmConfirm(
      context,
      title: l.pl_remove_title(plugin.title ?? plugin.name),
      message: l.pl_remove_message,
      confirmLabel: l.pl_remove_confirm,
      cancelLabel: l.delete_cancel,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(pluginsProvider.notifier).remove(plugin.name);
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    Plugin plugin,
    bool enabled,
  ) async {
    // Switching on is a grant: the permissions are shown first.
    if (enabled) {
      await _review(context, ref, plugin, fresh: false);
      return;
    }
    try {
      await ref
          .read(pluginsProvider.notifier)
          .setEnabled(plugin.name, enabled: false);
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final async = ref.watch(pluginsProvider);
    final list = async.value;
    if (list == null) {
      return async.hasError
          ? DlmErrorState(
              title: l.list_error_title,
              message: async.error.toString(),
              retryLabel: l.list_retry,
              onRetry: () => ref.invalidate(pluginsProvider),
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
            l.pl_intro,
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          SizedBox(height: gap),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: DlmButton(
              label: l.pl_install,
              icon: const DlmIcon(DlmIconName.plus),
              variant: DlmButtonVariant.primary,
              onPressed: () => unawaited(_install(context, ref)),
            ),
          ),
          SizedBox(height: gap),
          Expanded(
            child: list.isEmpty
                ? DlmEmptyState(
                    title: l.pl_empty_title,
                    message: l.pl_empty_message,
                  )
                : ListView(
                    children: [
                      for (final p in list)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: theme.metrics.spacing.xs,
                          ),
                          child: _PluginRow(
                            plugin: p,
                            onToggle: (v) =>
                                unawaited(_toggle(context, ref, p, v)),
                            onPermissions: () => unawaited(
                              _review(context, ref, p, fresh: false),
                            ),
                            onLogs: () => unawaited(
                              showDlmDialog<void>(
                                context,
                                semanticLabel: l.pl_logs_title(
                                  p.title ?? p.name,
                                ),
                                builder: (_) => PluginLogsDialog(plugin: p),
                              ),
                            ),
                            onRemove: () => unawaited(_remove(context, ref, p)),
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

class _PluginRow extends StatelessWidget {
  const _PluginRow({
    required this.plugin,
    required this.onToggle,
    required this.onPermissions,
    required this.onLogs,
    required this.onRemove,
  });

  final Plugin plugin;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPermissions;
  final VoidCallback onLogs;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final name = plugin.title ?? plugin.name;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.raised,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: EdgeInsets.all(theme.metrics.spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DlmSwitch(
                  value: plugin.enabled,
                  semanticLabel: l.pl_enabled(name),
                  onChanged: onToggle,
                ),
                SizedBox(width: theme.metrics.spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name  ${plugin.version}',
                        style: theme.typography.subtitle,
                      ),
                      if ((plugin.description ?? '').isNotEmpty)
                        Text(
                          plugin.description!,
                          style: theme.typography.caption.copyWith(
                            color: theme.colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                DlmButton(
                  label: l.pl_permissions,
                  variant: DlmButtonVariant.plain,
                  onPressed: onPermissions,
                ),
                DlmButton(
                  label: l.pl_logs,
                  variant: DlmButtonVariant.plain,
                  onPressed: onLogs,
                ),
                DlmIconButton(
                  icon: const DlmIcon(DlmIconName.trash),
                  semanticLabel: l.pl_remove(name),
                  size: DlmControlSize.small,
                  onPressed: onRemove,
                ),
              ],
            ),
            if ((plugin.error ?? '').isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: theme.metrics.spacing.xs),
                child: DlmBanner(tone: DlmTone.danger, message: plugin.error!),
              ),
          ],
        ),
      ),
    );
  }
}

/// Where a plugin is installed from, as typed.
class InstallDraft {
  /// A folder on the daemon's machine, or a git address.
  String source = '';

  /// A branch, tag or commit when [source] is a git address.
  String ref = '';

  /// Whether to replace a plugin of the same name.
  bool replace = false;

  /// Whether the draft can be installed.
  bool get valid => source.trim().isNotEmpty;
}

/// Asks where to install a plugin from; pops the [InstallDraft].
class InstallPluginDialog extends StatefulWidget {
  /// Creates the dialog.
  const InstallPluginDialog({super.key});

  @override
  State<InstallPluginDialog> createState() => _InstallPluginDialogState();
}

class _InstallPluginDialogState extends State<InstallPluginDialog> {
  final InstallDraft _draft = InstallDraft();
  final TextEditingController _source = TextEditingController();

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  Future<void> _browse() async {
    final chosen = await pickDaemonFolder(context);
    if (chosen != null && mounted) {
      setState(() {
        _source.text = chosen;
        _draft.source = chosen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final d = _draft;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: DlmDialogContent(
        title: l.pl_install_title,
        message: l.pl_install_message,
        child: DlmFormGroup(
          children: [
            DlmFormRow(
              label: l.pl_source,
              description: l.pl_source_desc,
              control: Row(
                children: [
                  Expanded(
                    child: DlmTextField(
                      controller: _source,
                      semanticLabel: l.pl_source,
                      placeholder: 'https://github.com/…',
                      onChanged: (v) => setState(() => d.source = v),
                    ),
                  ),
                  SizedBox(width: theme.metrics.spacing.xs),
                  DlmIconButton(
                    icon: const DlmIcon(DlmIconName.folder),
                    semanticLabel: l.add_folder_browse,
                    onPressed: () => unawaited(_browse()),
                  ),
                ],
              ),
            ),
            DlmFormRow(
              label: l.pl_ref,
              description: l.pl_ref_desc,
              control: DlmTextField(
                semanticLabel: l.pl_ref,
                onChanged: (v) => setState(() => d.ref = v),
              ),
            ),
            DlmFormRow(
              label: l.pl_replace,
              control: DlmSwitch(
                value: d.replace,
                semanticLabel: l.pl_replace,
                onChanged: (v) => setState(() => d.replace = v),
              ),
            ),
          ],
        ),
        actions: [
          DlmButton(
            label: l.files_cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
          DlmButton(
            label: l.pl_install_go,
            variant: DlmButtonVariant.primary,
            onPressed: d.valid ? () => Navigator.of(context).pop(d) : null,
          ),
        ],
      ),
    );
  }
}

/// What a plugin may do: the events it reacts to and the hosts it may contact.
/// Pops true when the user switches it on.
class PluginReviewDialog extends StatelessWidget {
  /// Creates the review of [plugin]; [fresh] after an installation.
  const PluginReviewDialog({
    required this.plugin,
    required this.fresh,
    super.key,
  });

  /// The plugin.
  final Plugin plugin;

  /// Whether it was just installed (switched off).
  final bool fresh;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final hooks = plugin.hooks ?? const <String>[];
    final hosts = plugin.net ?? const <String>[];
    Widget section(String title, List<String> items, String none) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.typography.subtitle),
        if (items.isEmpty)
          Text(
            none,
            style: theme.typography.caption.copyWith(
              color: theme.colors.textSecondary,
            ),
          )
        else
          Wrap(
            spacing: theme.metrics.spacing.xs,
            runSpacing: theme.metrics.spacing.xs,
            children: [for (final i in items) DlmBadge(label: i)],
          ),
      ],
    );
    final canEnable = !plugin.enabled;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: DlmDialogContent(
        title: l.pl_review_title(plugin.title ?? plugin.name),
        message: fresh ? l.pl_review_fresh : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if ((plugin.description ?? '').isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: theme.metrics.spacing.sm),
                child: Text(plugin.description!),
              ),
            Text(
              l.pl_review_source(plugin.source, plugin.version),
              style: theme.typography.caption.copyWith(
                color: theme.colors.textSecondary,
              ),
            ),
            SizedBox(height: theme.metrics.spacing.md),
            section(l.pl_hooks, hooks, l.pl_hooks_none),
            SizedBox(height: theme.metrics.spacing.md),
            section(l.pl_hosts, hosts, l.pl_hosts_none),
            SizedBox(height: theme.metrics.spacing.md),
            DlmBanner(tone: DlmTone.warning, message: l.pl_trust_warning),
          ],
        ),
        actions: [
          DlmButton(
            label: canEnable ? l.pl_keep_off : l.add_close,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          if (canEnable)
            DlmButton(
              label: l.pl_enable,
              variant: DlmButtonVariant.primary,
              onPressed: () => Navigator.of(context).pop(true),
            ),
        ],
      ),
    );
  }
}

/// The log of one plugin.
class PluginLogsDialog extends ConsumerWidget {
  /// Creates the dialog for [plugin].
  const PluginLogsDialog({required this.plugin, super.key});

  /// The plugin.
  final Plugin plugin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 720,
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: DlmDialogContent(
        title: l.pl_logs_title(plugin.title ?? plugin.name),
        child: Flexible(
          child: LogView(
            load: ({level, q}) => ref
                .read(pluginsProvider.notifier)
                .logs(plugin.name, level: level, q: q),
          ),
        ),
        actions: [
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
