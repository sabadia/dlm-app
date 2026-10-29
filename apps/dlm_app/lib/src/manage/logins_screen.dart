import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../shell/feedback.dart';
import 'credential_draft.dart';

/// The stored site logins. Passwords go to the daemon and never come back:
/// editing a login leaves the password alone unless a new one is typed.
class LoginsScreen extends ConsumerWidget {
  /// Creates the page.
  const LoginsScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    Credential? login,
  }) async {
    final l = AppLocalizations.of(context);
    final draft = await showDlmDialog<CredentialDraft>(
      context,
      semanticLabel: login == null ? l.login_add_title : l.login_edit_title,
      builder: (_) => LoginDialog(login: login),
    );
    if (draft == null || !context.mounted) return;
    try {
      final controller = ref.read(credentialsProvider.notifier);
      if (login == null) {
        await controller.create(draft.toCreate());
      } else {
        await controller.edit(login.id, draft.toUpdate(login));
      }
      if (context.mounted) showNotice(context, ref, l.login_saved);
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Credential login,
  ) async {
    final l = AppLocalizations.of(context);
    final ok = await showDlmConfirm(
      context,
      title: l.login_delete_title(login.host),
      message: l.login_delete_message,
      confirmLabel: l.login_delete_confirm,
      cancelLabel: l.delete_cancel,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(credentialsProvider.notifier).remove(login.id);
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final async = ref.watch(credentialsProvider);
    final list = async.value;
    if (list == null) {
      return async.hasError
          ? DlmErrorState(
              title: l.list_error_title,
              message: async.error.toString(),
              retryLabel: l.list_retry,
              onRetry: () => ref.invalidate(credentialsProvider),
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
            l.login_intro,
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          SizedBox(height: gap),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: DlmButton(
              label: l.login_add,
              icon: const DlmIcon(DlmIconName.plus),
              variant: DlmButtonVariant.primary,
              onPressed: () => unawaited(_edit(context, ref)),
            ),
          ),
          SizedBox(height: gap),
          Expanded(
            child: list.isEmpty
                ? DlmEmptyState(
                    title: l.login_empty_title,
                    message: l.login_empty_message,
                  )
                : ListView(
                    children: [
                      for (final c in list)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: theme.metrics.spacing.xs,
                          ),
                          child: DlmListRow(
                            title: c.host,
                            subtitle:
                                '${c.username} · ${c.scheme} · ${l.login_updated(DateFormat.yMMMd(l.localeName).format(c.updatedAt.toLocal()))}',
                            leading: const DlmIcon(DlmIconName.key),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DlmIconButton(
                                  icon: const DlmIcon(DlmIconName.edit),
                                  semanticLabel: l.login_edit(c.host),
                                  size: DlmControlSize.small,
                                  onPressed: () =>
                                      unawaited(_edit(context, ref, login: c)),
                                ),
                                DlmIconButton(
                                  icon: const DlmIcon(DlmIconName.trash),
                                  semanticLabel: l.login_delete(c.host),
                                  size: DlmControlSize.small,
                                  onPressed: () =>
                                      unawaited(_delete(context, ref, c)),
                                ),
                              ],
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

/// The add/edit dialog of a login; pops the [CredentialDraft].
class LoginDialog extends StatefulWidget {
  /// Creates the dialog; [login] is null for a new one.
  const LoginDialog({this.login, super.key});

  /// The login being edited.
  final Credential? login;

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  late final CredentialDraft _draft = CredentialDraft(from: widget.login);
  late final TextEditingController _host = TextEditingController(
    text: _draft.host,
  );
  late final TextEditingController _user = TextEditingController(
    text: _draft.username,
  );
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _host.dispose();
    _user.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = _draft;
    final body = DlmFormGroup(
      children: [
        DlmFormRow(
          label: l.login_host,
          description: l.login_host_desc,
          control: DlmTextField(
            controller: _host,
            semanticLabel: l.login_host,
            onChanged: (v) => setState(() => d.host = v),
          ),
        ),
        DlmFormRow(
          label: l.login_user,
          control: DlmTextField(
            controller: _user,
            semanticLabel: l.login_user,
            onChanged: (v) => setState(() => d.username = v),
          ),
        ),
        DlmFormRow(
          label: l.login_password,
          description: d.isNew ? null : l.login_password_keep,
          control: DlmPasswordField(
            controller: _password,
            semanticLabel: l.login_password,
            showLabel: l.field_show,
            hideLabel: l.field_hide,
            onChanged: (v) => setState(() => d.password = v),
          ),
        ),
        DlmFormRow(
          label: l.login_scheme,
          control: SizedBox(
            width: 200,
            child: DlmDropdown<CreateCredentialBodyScheme>(
              semanticLabel: l.login_scheme,
              value: d.scheme,
              choices: [
                DlmChoice(
                  value: CreateCredentialBodyScheme.auto,
                  label: l.login_scheme_auto,
                ),
                DlmChoice(
                  value: CreateCredentialBodyScheme.basic,
                  label: l.login_scheme_basic,
                ),
                DlmChoice(
                  value: CreateCredentialBodyScheme.digest,
                  label: l.login_scheme_digest,
                ),
              ],
              onChanged: (v) => setState(() => d.scheme = v),
            ),
          ),
        ),
      ],
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: DlmDialogContent(
        title: widget.login == null ? l.login_add_title : l.login_edit_title,
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
