import 'dart:async';

import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import '../connection/connection_controller.dart';
import '../manage/access_screen.dart';
import '../platform/startup.dart';
import '../routing/app_routes.dart';
import '../shell/feedback.dart';

/// The rows of the setup that touch this computer rather than the daemon:
/// start at login and the browser extension.
class SystemRows extends ConsumerWidget {
  /// Creates the rows.
  const SystemRows({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final login = ref.watch(loginItemEnabledProvider);
    final host = ref.watch(nativeHostProvider);
    final installed = host.value?.browsers
        ?.where((b) => b.status == 'installed')
        .length;
    final (extText, extTone) = switch (host) {
      AsyncData() when (installed ?? 0) > 0 => (
        l.setup_ext_connected(installed!),
        DlmTone.success,
      ),
      AsyncData() => (l.setup_ext_none, DlmTone.neutral),
      AsyncError() => (l.setup_ext_unknown, DlmTone.warning),
      _ => ('…', DlmTone.neutral),
    };
    final theme = DlmTheme.of(context);
    final isLocal = ref.watch(activeProfileProvider).isLocal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DlmFormGroup(
          title: l.setup_system_title,
          footer: l.setup_system_desc,
          children: [
            DlmFormRow(
              label: l.setup_login,
              description: l.setup_login_desc,
              control: DlmSwitch(
                value: login.value ?? false,
                semanticLabel: l.setup_login,
                onChanged: login.isLoading
                    ? null
                    : (v) => unawaited(() async {
                        try {
                          await ref
                              .read(loginItemEnabledProvider.notifier)
                              .set(enabled: v);
                        } on Object catch (e) {
                          if (context.mounted) showFailure(context, ref, e);
                        }
                      }()),
              ),
            ),
            // The native host lives on the daemon's computer.
            if (isLocal)
              DlmFormRow(
                label: l.setup_ext,
                description: l.setup_ext_desc,
                control: DlmBadge(label: extText, tone: extTone),
              ),
          ],
        ),
        if (isLocal) ...[
          SizedBox(height: theme.metrics.spacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: DlmButton(
              label: l.setup_ext_open,
              variant: DlmButtonVariant.plain,
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(routerProvider).go(managePath('access'));
              },
            ),
          ),
        ],
      ],
    );
  }
}
