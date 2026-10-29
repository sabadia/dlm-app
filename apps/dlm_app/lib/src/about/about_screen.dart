import 'dart:async';
import 'dart:io' show Platform;

import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connection/connection_controller.dart';
import '../shell/feedback.dart';
import 'diagnostics_providers.dart';
import 'licences_dialog.dart';

/// About the app and the daemon it talks to: versions, whether they work
/// together, a diagnostics text to give to support, and the open-source
/// licences of everything in the build.
class AboutScreen extends ConsumerWidget {
  /// Creates the page.
  const AboutScreen({super.key});

  Future<void> _copyDiagnostics(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    // Read before the first await: the context is not used after it.
    final locale = Localizations.localeOf(context).toString();
    try {
      final info = ref.read(systemInfoProvider).value;
      final text = buildDiagnostics(
        redactor: ref.read(redactorProvider),
        appVersion: appVersion,
        operatingSystem:
            '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
        profiles: await ref.read(profileStoreProvider).load(),
        logger: ref.read(appLoggerProvider),
        locale: locale,
        daemonInfo: info?.toJson(),
        activeProfileId: ref.read(activeProfileProvider).id,
      );
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) showNotice(context, ref, l.ab_diagnostics_copied);
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final info = ref.watch(systemInfoProvider).value;
    final gap = SizedBox(height: theme.metrics.spacing.lg);
    final String compat;
    if (info == null) {
      compat = l.ab_compat_unknown;
    } else if (info.minClientApi > appApiVersion) {
      compat = l.ab_compat_app_old;
    } else if (info.apiVersion < oldestDaemonApi) {
      compat = l.ab_compat_daemon_old;
    } else {
      compat = l.ab_compat_ok;
    }

    return ListView(
      padding: EdgeInsets.all(theme.metrics.spacing.lg),
      children: [
        Text(l.ab_title, style: theme.typography.title),
        SizedBox(height: theme.metrics.spacing.xs),
        Text(
          l.ab_blurb,
          style: theme.typography.body.copyWith(
            color: theme.colors.textSecondary,
          ),
        ),
        gap,
        DlmFormGroup(
          title: l.ab_app,
          children: [
            DlmFormRow(label: l.ab_version, control: const Text(appVersion)),
            DlmFormRow(
              label: l.ab_api,
              control: Text(l.ab_api_value(appApiVersion, oldestDaemonApi)),
            ),
            DlmFormRow(
              label: l.ab_system,
              control: Text(
                '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
              ),
            ),
          ],
        ),
        gap,
        DlmFormGroup(
          title: l.ab_daemon,
          children: [
            DlmFormRow(
              label: l.ab_version,
              control: Text(
                info == null
                    ? '…'
                    : '${info.version}${info.commit == null ? '' : ' (${info.commit})'}',
              ),
            ),
            if (info != null) ...[
              DlmFormRow(
                label: l.ab_api,
                control: Text(
                  l.ab_api_value(info.apiVersion, info.minClientApi),
                ),
              ),
              DlmFormRow(
                label: l.ab_system,
                control: Text('${info.os} ${info.arch}'),
              ),
              DlmFormRow(label: l.ab_address, control: Text(info.address)),
            ],
            DlmFormRow(label: l.ab_compat, control: Text(compat)),
          ],
        ),
        gap,
        DlmFormGroup(
          title: l.ab_support,
          footer: l.ab_diagnostics_desc,
          children: [
            DlmFormRow(
              label: l.ab_diagnostics,
              control: DlmButton(
                label: l.ab_diagnostics_copy,
                icon: const DlmIcon(DlmIconName.copy),
                onPressed: () => unawaited(_copyDiagnostics(context, ref)),
              ),
            ),
          ],
        ),
        gap,
        DlmFormGroup(
          title: l.ab_licences,
          footer: l.ab_licences_desc,
          children: [
            DlmFormRow(
              label: l.ab_licences_list,
              control: DlmButton(
                label: l.ab_licences_show,
                onPressed: () => unawaited(
                  showDlmDialog<void>(
                    context,
                    semanticLabel: l.ab_licences,
                    builder: (_) => const LicencesDialog(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
