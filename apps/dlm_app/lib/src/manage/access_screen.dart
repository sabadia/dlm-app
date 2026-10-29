import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../connection/connection_controller.dart';
import '../shell/feedback.dart';

/// Who the app's token says it is.
final whoamiProvider = FutureProvider.autoDispose<WhoAmI>(
  (ref) => ref.watch(daemonRepositoryProvider).whoami(),
);

/// The named tokens.
final tokensProvider = FutureProvider.autoDispose<List<Token>>(
  (ref) => ref.watch(daemonRepositoryProvider).tokens(),
);

/// Whether the browser extension's native host is installed.
final nativeHostProvider = FutureProvider.autoDispose<NativeHostStatus>(
  (ref) => ref.watch(daemonRepositoryProvider).nativeHost(),
);

/// The MCP address of the daemon the app is connected to.
String mcpUrl(String baseUrl) =>
    '${baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl}/mcp';

/// Access to the daemon: the token the app uses, named tokens for other
/// clients, the browser extension's native host, and ready-made settings for
/// assistants that speak MCP.
class AccessScreen extends ConsumerStatefulWidget {
  /// Creates the page.
  const AccessScreen({super.key});

  @override
  ConsumerState<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends ConsumerState<AccessScreen> {
  final TextEditingController _extensionIds = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _extensionIds.dispose();
    super.dispose();
  }

  Future<void> _showSecret(String title, String token) async {
    final l = AppLocalizations.of(context);
    await showDlmDialog<void>(
      context,
      semanticLabel: title,
      builder: (_) => _SecretDialog(title: title, secret: token),
    );
    if (mounted) {
      // The secret is not kept anywhere else.
      showNotice(context, ref, l.ac_secret_gone);
    }
  }

  Future<void> _addToken() async {
    final l = AppLocalizations.of(context);
    final draft =
        await showDlmDialog<({String name, CreateTokenBodyScope scope})>(
          context,
          semanticLabel: l.ac_add_title,
          builder: (_) => const _AddTokenDialog(),
        );
    if (draft == null || !mounted) return;
    try {
      final created = await ref
          .read(daemonRepositoryProvider)
          .createToken(draft.name, draft.scope);
      ref.invalidate(tokensProvider);
      if (mounted) {
        await _showSecret(l.ac_created_title(draft.name), created.token);
      }
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _deleteToken(Token t) async {
    final l = AppLocalizations.of(context);
    final ok = await showDlmConfirm(
      context,
      title: l.ac_delete_title(t.name),
      message: l.ac_delete_message,
      confirmLabel: l.ac_delete_confirm,
      cancelLabel: l.delete_cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(daemonRepositoryProvider).deleteToken(t.id);
      ref.invalidate(tokensProvider);
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _rotate() async {
    final l = AppLocalizations.of(context);
    final ok = await showDlmConfirm(
      context,
      title: l.ac_rotate_title,
      message: l.ac_rotate_message,
      confirmLabel: l.ac_rotate_confirm,
      cancelLabel: l.delete_cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      final created = await ref.read(daemonRepositoryProvider).rotateToken();
      // The old token is dead: keep the app signed in with the new one.
      final profile = ref.read(activeProfileProvider);
      if (!profile.isLocal) {
        await ref
            .read(profileStoreProvider)
            .save(profile, token: created.token);
      }
      // Show the secret first: reconnecting replaces the whole window.
      if (mounted) await _showSecret(l.ac_rotated_title, created.token);
      unawaited(ref.read(connectionProvider.notifier).connect());
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _nativeHost(NativeHostRequestAction action) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final ids = [
        for (final id in _extensionIds.text.split(RegExp(r'[\s,]+')))
          if (id.isNotEmpty) id,
      ];
      final results = await ref
          .read(daemonRepositoryProvider)
          .updateNativeHost(action, extensionIds: ids);
      ref.invalidate(nativeHostProvider);
      if (!mounted) return;
      final done = results
          .where((r) => r.status == 'installed' || r.status == 'removed')
          .length;
      showNotice(context, ref, l.ac_nh_done(done));
    } on Object catch (e) {
      // 403 native_host.local_only from another machine.
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy(String text) async {
    final l = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) showNotice(context, ref, l.ck_copied);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final gap = SizedBox(height: theme.metrics.spacing.lg);
    final me = ref.watch(whoamiProvider).value;
    final tokens = ref.watch(tokensProvider);
    final host = ref.watch(nativeHostProvider);
    final base = ref.watch(sessionProvider).api.dio.options.baseUrl;
    final url = mcpUrl(base);
    final date = DateFormat.yMMMd(l.localeName);
    final canManage = me == null || me.scope == WhoAmIScope.admin;
    final claude =
        'claude mcp add --transport http dlm $url \\\n  --header "Authorization: Bearer <token>"';
    final json =
        '{\n  "mcpServers": {\n    "dlm": {\n      "type": "http",\n      "url": "$url",\n      "headers": { "Authorization": "Bearer <token>" }\n    }\n  }\n}';

    return ListView(
      padding: EdgeInsets.all(theme.metrics.spacing.lg),
      children: [
        DlmFormGroup(
          title: l.ac_identity,
          children: [
            DlmFormRow(
              label: l.ac_signed_in,
              control: Text(
                me == null
                    ? '…'
                    : l.ac_who(
                        me.name,
                        me.scope == WhoAmIScope.admin
                            ? l.ac_scope_admin
                            : l.ac_scope_read,
                        me.primary ? l.ac_primary : l.ac_named,
                      ),
              ),
            ),
            if (canManage)
              DlmFormRow(
                label: l.ac_rotate,
                description: l.ac_rotate_desc,
                control: DlmButton(
                  label: l.ac_rotate,
                  onPressed: () => unawaited(_rotate()),
                ),
              ),
          ],
        ),
        gap,
        Text(l.ac_tokens, style: theme.typography.subtitle),
        Text(
          l.ac_tokens_desc,
          style: theme.typography.caption.copyWith(
            color: theme.colors.textSecondary,
          ),
        ),
        SizedBox(height: theme.metrics.spacing.xs),
        if (canManage)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: DlmButton(
              label: l.ac_add,
              icon: const DlmIcon(DlmIconName.plus),
              variant: DlmButtonVariant.primary,
              onPressed: () => unawaited(_addToken()),
            ),
          ),
        SizedBox(height: theme.metrics.spacing.xs),
        ...tokens.when(
          data: (list) => list.isEmpty
              ? [Text(l.ac_tokens_none)]
              : [
                  for (final t in list)
                    DlmListRow(
                      title: t.name,
                      subtitle:
                          '${t.scope == 'read' ? l.ac_scope_read : l.ac_scope_admin} · ${l.ac_created(date.format(t.createdAt.toLocal()))} · ${t.lastUsedAt == null ? l.ac_never_used : l.ac_last_used(date.format(t.lastUsedAt!.toLocal()))}',
                      leading: const DlmIcon(DlmIconName.key),
                      trailing: canManage
                          ? DlmIconButton(
                              icon: const DlmIcon(DlmIconName.trash),
                              semanticLabel: l.ac_delete(t.name),
                              size: DlmControlSize.small,
                              onPressed: () => unawaited(_deleteToken(t)),
                            )
                          : null,
                    ),
                ],
          loading: () => [DlmLoadingState(label: l.list_loading)],
          error: (e, _) => [
            DlmBanner(tone: DlmTone.danger, message: l.ac_tokens_error),
          ],
        ),
        gap,
        DlmFormGroup(
          title: l.ac_nh_title,
          footer: l.ac_nh_desc,
          children: [
            ...host.when(
              data: (s) => [
                for (final b in s.browsers ?? const <Result>[])
                  DlmFormRow(
                    label: b.browser,
                    control: DlmBadge(
                      label: b.status,
                      tone: b.status == 'installed'
                          ? DlmTone.success
                          : DlmTone.neutral,
                    ),
                  ),
                DlmFormRow(
                  label: l.ac_nh_origins,
                  control: Text(
                    (s.allowedOrigins ?? const []).isEmpty
                        ? l.ac_nh_no_origins
                        : s.allowedOrigins!.join(', '),
                  ),
                ),
              ],
              loading: () => [DlmLoadingState(label: l.list_loading)],
              error: (e, _) => [
                DlmBanner(tone: DlmTone.warning, message: l.ac_nh_error),
              ],
            ),
            DlmFormRow(
              label: l.ac_nh_ids,
              description: l.ac_nh_ids_desc,
              control: SizedBox(
                width: 360,
                child: DlmTextField(
                  controller: _extensionIds,
                  semanticLabel: l.ac_nh_ids,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: theme.metrics.spacing.sm),
        Wrap(
          spacing: theme.metrics.spacing.sm,
          children: [
            DlmButton(
              label: l.ac_nh_install,
              onPressed: _busy
                  ? null
                  : () =>
                        unawaited(_nativeHost(NativeHostRequestAction.install)),
            ),
            DlmButton(
              label: l.ac_nh_remove,
              onPressed: _busy
                  ? null
                  : () => unawaited(
                      _nativeHost(NativeHostRequestAction.uninstall),
                    ),
            ),
          ],
        ),
        gap,
        Text(l.ac_mcp_title, style: theme.typography.subtitle),
        Text(
          l.ac_mcp_desc,
          style: theme.typography.caption.copyWith(
            color: theme.colors.textSecondary,
          ),
        ),
        SizedBox(height: theme.metrics.spacing.xs),
        _Snippet(
          title: l.ac_mcp_url,
          text: url,
          copyLabel: l.ck_copy,
          onCopy: () => unawaited(_copy(url)),
        ),
        _Snippet(
          title: l.ac_mcp_claude,
          text: claude,
          copyLabel: l.ck_copy,
          onCopy: () => unawaited(_copy(claude)),
        ),
        _Snippet(
          title: l.ac_mcp_json,
          text: json,
          copyLabel: l.ck_copy,
          onCopy: () => unawaited(_copy(json)),
        ),
        DlmBanner(message: l.ac_mcp_token_note),
      ],
    );
  }
}

class _Snippet extends StatelessWidget {
  const _Snippet({
    required this.title,
    required this.text,
    required this.copyLabel,
    required this.onCopy,
  });

  final String title;
  final String text;
  final String copyLabel;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: theme.metrics.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.typography.caption)),
              DlmButton(
                label: copyLabel,
                icon: const DlmIcon(DlmIconName.copy),
                variant: DlmButtonVariant.plain,
                onPressed: onCopy,
              ),
            ],
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.raised,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: EdgeInsets.all(theme.metrics.spacing.sm),
              child: Text(text, style: theme.typography.caption),
            ),
          ),
        ],
      ),
    );
  }
}

/// A secret shown once, with a way to copy it.
class _SecretDialog extends StatelessWidget {
  const _SecretDialog({required this.title, required this.secret});

  final String title;
  final String secret;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: DlmDialogContent(
        title: title,
        message: l.ac_secret_once,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.raised,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: EdgeInsets.all(theme.metrics.spacing.sm),
                child: Text(secret, style: theme.typography.caption),
              ),
            ),
            SizedBox(height: theme.metrics.spacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: DlmButton(
                label: l.ck_copy,
                icon: const DlmIcon(DlmIconName.copy),
                onPressed: () => Clipboard.setData(ClipboardData(text: secret)),
              ),
            ),
          ],
        ),
        actions: [
          DlmButton(
            label: l.ac_secret_done,
            variant: DlmButtonVariant.primary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _AddTokenDialog extends StatefulWidget {
  const _AddTokenDialog();

  @override
  State<_AddTokenDialog> createState() => _AddTokenDialogState();
}

class _AddTokenDialogState extends State<_AddTokenDialog> {
  String _name = '';
  CreateTokenBodyScope _scope = CreateTokenBodyScope.read;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: DlmDialogContent(
        title: l.ac_add_title,
        child: DlmFormGroup(
          children: [
            DlmFormRow(
              label: l.ac_name,
              control: DlmTextField(
                semanticLabel: l.ac_name,
                placeholder: l.ac_name_hint,
                onChanged: (v) => setState(() => _name = v),
              ),
            ),
            DlmFormRow(
              label: l.ac_scope,
              description: l.ac_scope_desc,
              control: SizedBox(
                width: 220,
                child: DlmDropdown<CreateTokenBodyScope>(
                  semanticLabel: l.ac_scope,
                  value: _scope,
                  choices: [
                    DlmChoice(
                      value: CreateTokenBodyScope.read,
                      label: l.ac_scope_read,
                    ),
                    DlmChoice(
                      value: CreateTokenBodyScope.admin,
                      label: l.ac_scope_admin,
                    ),
                  ],
                  onChanged: (v) => setState(() => _scope = v),
                ),
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
            label: l.ac_create,
            variant: DlmButtonVariant.primary,
            onPressed: _name.trim().isEmpty
                ? null
                : () =>
                      Navigator.of(context)
                          .pop((name: _name.trim(), scope: _scope)),
          ),
        ],
      ),
    );
  }
}
