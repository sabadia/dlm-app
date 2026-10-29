import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connection/connection_controller.dart';
import '../prefs/pref_providers.dart';
import '../shell/feedback.dart';
import 'folder_picker.dart';
import 'tool_row.dart';

/// Shows the setup dialog on the first run of the app with its own download
/// service. A remote profile belongs to somebody else's computer, so nothing
/// is asked about it.
Future<void> showSetupOnFirstRun(BuildContext context, WidgetRef ref) async {
  if (!ref.read(activeProfileProvider).isLocal) return;
  if (ref.read(onboardingDoneProvider)) return;
  await showSetup(context, ref);
}

/// Shows the setup and health check; closing it counts as done.
Future<void> showSetup(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  await showDlmDialog<void>(
    context,
    semanticLabel: l.setup_title,
    builder: (_) => const SetupDialog(),
  );
  await ref.read(onboardingDoneProvider.notifier).set(true);
}

/// The first-run setup: where downloads go and what helper programs the
/// download service found. It is also the health check, reachable from the
/// command palette.
class SetupDialog extends ConsumerWidget {
  /// Creates the dialog.
  const SetupDialog({super.key});

  Future<void> _chooseFolder(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final l = AppLocalizations.of(context);
    final path = await ref
        .read(folderPickerProvider)
        .pick(initial: current, title: l.setup_folder_dialog);
    if (path == null || !context.mounted) return;
    try {
      await ref.read(globalSettingsProvider.notifier).patch({
        'downloadDir': path,
      });
      if (context.mounted) {
        showNotice(context, ref, l.setup_folder_saved(path));
      }
    } on Object catch (e) {
      if (context.mounted) showFailure(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final settings = ref.watch(globalSettingsProvider).value;
    final folder =
        settings?.settings.downloadDir ?? settings?.defaults.downloadDir;
    final info = ref.watch(systemInfoProvider);
    final gap = SizedBox(height: theme.metrics.spacing.lg);

    final tools = info.when(
      data: (i) => [
        for (final (name, label, desc) in [
          (
            ToolStatusName.ffmpeg,
            l.setup_tool_ffmpeg,
            l.setup_tool_ffmpeg_desc,
          ),
          (ToolStatusName.ytDlp, l.setup_tool_ytdlp, l.setup_tool_ytdlp_desc),
          (
            ToolStatusName.browser,
            l.setup_tool_browser,
            l.setup_tool_browser_desc,
          ),
        ])
          ToolStatusRow(
            label: label,
            description: desc,
            status: (i.tools ?? const <ToolStatus>[])
                .where((t) => t.name == name)
                .firstOrNull,
          ),
      ],
      loading: () => [
        Padding(
          padding: EdgeInsets.all(theme.metrics.spacing.lg),
          child: DlmLoadingState(label: l.setup_tools_loading),
        ),
      ],
      error: (e, _) => [
        DlmErrorState(
          title: l.list_error_title,
          message: e.toString(),
          retryLabel: l.list_retry,
          onRetry: () => ref.invalidate(systemInfoProvider),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 560,
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: DlmDialogContent(
        title: l.setup_title,
        message: l.setup_intro,
        child: Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DlmFormGroup(
                  title: l.setup_folder_title,
                  footer: l.setup_folder_desc,
                  children: [
                    DlmFormRow(
                      label: folder ?? l.setup_folder_unset,
                      control: DlmButton(
                        label: l.setup_folder_choose,
                        icon: const DlmIcon(DlmIconName.folder),
                        onPressed: settings == null
                            ? null
                            : () => unawaited(
                                _chooseFolder(context, ref, folder),
                              ),
                      ),
                    ),
                  ],
                ),
                gap,
                DlmFormGroup(
                  title: l.setup_tools_title,
                  footer: l.setup_tools_desc,
                  children: tools,
                ),
                SizedBox(height: theme.metrics.spacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: DlmButton(
                    label: l.setup_tools_recheck,
                    icon: const DlmIcon(DlmIconName.refresh),
                    variant: DlmButtonVariant.plain,
                    onPressed: () => ref.invalidate(systemInfoProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          DlmButton(
            label: l.setup_done,
            variant: DlmButtonVariant.primary,
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
