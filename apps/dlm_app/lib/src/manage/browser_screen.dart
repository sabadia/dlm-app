import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../onboarding/tool_row.dart';
import '../shell/feedback.dart';

/// The browser tool: open a page in the daemon's headless browser, see the
/// downloads it leads to and take one; the browser profiles (one per site
/// group); and what the daemon found of its external programs.
class BrowserScreen extends ConsumerStatefulWidget {
  /// Creates the page.
  const BrowserScreen({super.key});

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  String _url = '';
  bool _opening = false;
  PageResult? _result;
  Object? _error;

  bool get _urlValid {
    final uri = Uri.tryParse(_url.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<void> _open() async {
    setState(() {
      _opening = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(browserRepositoryProvider)
          .resolve(_url.trim());
      if (!mounted) return;
      setState(() => _result = result);
      // The page may have stored cookies and opened a profile.
      ref
        ..invalidate(browserProfilesProvider)
        ..invalidate(browserStatusProvider);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _download(PageResult result, Candidate c) async {
    final l = AppLocalizations.of(context);
    try {
      final task = await ref
          .read(browserRepositoryProvider)
          .download(result.id, c.index);
      ref.read(taskStoreProvider).tasks.put(task.id, task);
      if (mounted) {
        showNotice(context, ref, l.br_added(task.name ?? c.filename ?? c.url));
      }
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _deleteProfile(String group) async {
    final l = AppLocalizations.of(context);
    final ok = await showDlmConfirm(
      context,
      title: l.br_profile_delete_title(group),
      message: l.br_profile_delete_message,
      confirmLabel: l.br_profile_delete_confirm,
      cancelLabel: l.delete_cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(browserRepositoryProvider).deleteProfile(group);
      ref.invalidate(browserProfilesProvider);
    } on Object catch (e) {
      // 409 while the group's browser is running.
      if (mounted) showFailure(context, ref, e);
    }
  }

  Widget _candidates(AppLocalizations l, DlmThemeData theme, PageResult r) {
    final list = r.candidates ?? const <Candidate>[];
    if (list.isEmpty) return DlmEmptyState(title: l.br_none);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final c in list)
          Padding(
            padding: EdgeInsets.only(bottom: theme.metrics.spacing.xs),
            child: DlmListRow(
              title: c.filename ?? c.url,
              subtitle: [
                c.kind,
                if ((c.mime ?? '').isNotEmpty) c.mime!,
                if (c.size > 0) formatBytes(c.size) ?? '',
                c.source,
              ].where((e) => e.isNotEmpty).join(' · '),
              leading: const DlmIcon(DlmIconName.download),
              trailing: DlmButton(
                label: l.br_download,
                onPressed: () => unawaited(_download(r, c)),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final gap = SizedBox(height: theme.metrics.spacing.md);
    final result = _result;
    final profiles = ref.watch(browserProfilesProvider);
    final status = ref.watch(browserStatusProvider).value;
    final tools = ref.watch(systemInfoProvider).value?.tools;
    ToolStatus? tool(ToolStatusName n) =>
        tools?.where((t) => t.name == n).firstOrNull;

    return ListView(
      padding: EdgeInsets.all(theme.metrics.spacing.lg),
      children: [
        Text(
          l.br_intro,
          style: theme.typography.body.copyWith(
            color: theme.colors.textSecondary,
          ),
        ),
        gap,
        DlmFormGroup(
          title: l.br_open_title,
          children: [
            DlmFormRow(
              label: l.br_url,
              control: SizedBox(
                width: 560,
                child: Row(
                  children: [
                    Expanded(
                      child: DlmTextField(
                        semanticLabel: l.br_url,
                        placeholder: 'https://example.com/page',
                        errorText: _url.isEmpty || _urlValid
                            ? null
                            : l.br_url_invalid,
                        onChanged: (v) => setState(() => _url = v),
                        onSubmitted: (_) {
                          if (_urlValid && !_opening) unawaited(_open());
                        },
                      ),
                    ),
                    SizedBox(width: theme.metrics.spacing.sm),
                    DlmButton(
                      label: _opening ? l.br_opening : l.br_open,
                      variant: DlmButtonVariant.primary,
                      onPressed: _urlValid && !_opening
                          ? () => unawaited(_open())
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          gap,
          DlmBanner(tone: DlmTone.danger, message: l.br_error),
        ],
        if (result != null) ...[
          gap,
          Text(
            result.title.isEmpty ? result.finalUrl : result.title,
            style: theme.typography.subtitle,
          ),
          Text(
            l.br_result_info(result.finalUrl, result.group),
            style: theme.typography.caption.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          SizedBox(height: theme.metrics.spacing.sm),
          _candidates(l, theme, result),
        ],
        gap,
        DlmFormGroup(
          title: l.br_profiles_title,
          footer: l.br_profiles_desc,
          children: [
            ...profiles.when(
              data: (groups) => groups.isEmpty
                  ? [
                      Padding(
                        padding: EdgeInsets.all(theme.metrics.spacing.sm),
                        child: Text(l.br_profiles_none),
                      ),
                    ]
                  : [
                      for (final g in groups)
                        DlmListRow(
                          title: g,
                          leading: const DlmIcon(DlmIconName.globe),
                          trailing: DlmIconButton(
                            icon: const DlmIcon(DlmIconName.trash),
                            semanticLabel: l.br_profile_delete(g),
                            size: DlmControlSize.small,
                            onPressed: () => unawaited(_deleteProfile(g)),
                          ),
                        ),
                    ],
              loading: () => [DlmLoadingState(label: l.list_loading)],
              error: (e, _) => [
                DlmBanner(tone: DlmTone.danger, message: l.br_profiles_error),
              ],
            ),
          ],
        ),
        gap,
        DlmFormGroup(
          title: l.br_state_title,
          children: [
            DlmFormRow(
              label: l.br_state_in_use,
              control: Text(
                status?.browser == null
                    ? l.br_state_unused
                    : '${status!.browser!.name} ${status.browser!.version ?? ''}'
                          .trim(),
              ),
            ),
            DlmFormRow(
              label: l.br_state_running,
              control: Text(
                (status?.running ?? const []).isEmpty
                    ? l.br_state_none
                    : status!.running!
                          .map((r) => '${r.group} (${r.sessions})')
                          .join(', '),
              ),
            ),
            if (status != null)
              DlmFormRow(label: l.br_state_max, control: Text('${status.max}')),
          ],
        ),
        gap,
        DlmFormGroup(
          title: l.br_tools_title,
          children: [
            ToolStatusRow(
              label: l.setup_tool_ffmpeg,
              description: l.setup_tool_ffmpeg_desc,
              status: tool(ToolStatusName.ffmpeg),
            ),
            ToolStatusRow(
              label: l.setup_tool_ytdlp,
              description: l.setup_tool_ytdlp_desc,
              status: tool(ToolStatusName.ytDlp),
            ),
            ToolStatusRow(
              label: l.setup_tool_browser,
              description: l.setup_tool_browser_desc,
              status: tool(ToolStatusName.browser),
            ),
          ],
        ),
      ],
    );
  }
}
