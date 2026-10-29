import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../add/add_dialog.dart' show addFilePickerProvider;
import '../shell/feedback.dart';

/// Saves [content] as a text file the user names; false when cancelled. A seam
/// for tests.
final saveTextFileProvider =
    Provider<Future<bool> Function(String suggestedName, String content)>(
      (ref) => (name, content) async {
        final location = await getSaveLocation(suggestedName: name);
        if (location == null) return false;
        await XFile.fromData(
          Uint8List.fromList(content.codeUnits),
          mimeType: 'text/plain',
          name: name,
        ).saveTo(location.path);
        return true;
      },
    );

/// How an imported cookie file is read, from its name.
ImportCookiesBodyFormat cookieFormatOf(String fileName) =>
    fileName.toLowerCase().endsWith('.json')
    ? ImportCookiesBodyFormat.valueJson
    : ImportCookiesBodyFormat.netscape;

/// The stored cookies by domain, with import, export and deletion. Cookie
/// values are never shown here: they come only with an export, which the user
/// asks for and reveals on purpose.
class CookiesScreen extends ConsumerStatefulWidget {
  /// Creates the page.
  const CookiesScreen({super.key});

  @override
  ConsumerState<CookiesScreen> createState() => _CookiesScreenState();
}

class _CookiesScreenState extends ConsumerState<CookiesScreen> {
  Set<Object>? _expanded;

  Future<void> _import() async {
    final l = AppLocalizations.of(context);
    try {
      final picked = await ref.read(addFilePickerProvider)();
      if (picked == null || !mounted) return;
      final result = await ref
          .read(cookiesProvider.notifier)
          .import(
            ImportCookiesBody(
              data: picked.content,
              format: cookieFormatOf(picked.name),
            ),
          );
      if (!mounted) return;
      await showDlmDialog<void>(
        context,
        semanticLabel: l.ck_import_title(picked.name),
        builder: (_) => _ImportResult(name: picked.name, result: result),
      );
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _export({String? domain}) async {
    final l = AppLocalizations.of(context);
    await showDlmDialog<void>(
      context,
      semanticLabel: l.ck_export_title,
      builder: (_) => CookieExportDialog(domain: domain),
    );
  }

  Future<void> _deleteDomain(String domain, int count) async {
    final l = AppLocalizations.of(context);
    final ok = await showDlmConfirm(
      context,
      title: l.ck_delete_domain_title(domain),
      message: l.ck_delete_domain_message(count),
      confirmLabel: l.ck_delete_confirm,
      cancelLabel: l.delete_cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(cookiesProvider.notifier).removeDomain(domain);
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    }
  }

  Future<void> _deleteCookie(CookieInfo cookie) async {
    try {
      await ref.read(cookiesProvider.notifier).removeCookie(cookie.id);
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    }
  }

  List<DlmTreeNode> _tree(AppLocalizations l, List<CookieInfo> cookies) {
    final theme = DlmTheme.of(context);
    final byDomain = <String, List<CookieInfo>>{};
    for (final c in cookies) {
      byDomain.putIfAbsent(c.domain, () => []).add(c);
    }
    final domains = byDomain.keys.toList()..sort();
    final date = DateFormat.yMMMd(l.localeName);
    return [
      for (final d in domains)
        DlmTreeNode(
          id: 'domain:$d',
          label: d,
          icon: const DlmIcon(DlmIconName.globe),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.ck_count(byDomain[d]!.length)),
              DlmIconButton(
                icon: const DlmIcon(DlmIconName.exportIcon),
                semanticLabel: l.ck_export_domain(d),
                size: DlmControlSize.small,
                onPressed: () => unawaited(_export(domain: d)),
              ),
              DlmIconButton(
                icon: const DlmIcon(DlmIconName.trash),
                semanticLabel: l.ck_delete_domain(d),
                size: DlmControlSize.small,
                onPressed: () =>
                    unawaited(_deleteDomain(d, byDomain[d]!.length)),
              ),
            ],
          ),
          children: [
            for (final c in byDomain[d]!)
              DlmTreeNode(
                id: 'cookie:${c.id}',
                label: '${c.name}  ${c.path}',
                icon: const DlmIcon(DlmIconName.key),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (c.secure) DlmBadge(label: l.ck_secure),
                    if (c.httpOnly) DlmBadge(label: l.ck_http_only),
                    Text(
                      c.expiresAt == null
                          ? l.ck_session
                          : date.format(c.expiresAt!.toLocal()),
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.textSecondary,
                      ),
                    ),
                    DlmIconButton(
                      icon: const DlmIcon(DlmIconName.trash),
                      semanticLabel: l.ck_delete_cookie(c.name),
                      size: DlmControlSize.small,
                      onPressed: () => unawaited(_deleteCookie(c)),
                    ),
                  ],
                ),
              ),
          ],
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final async = ref.watch(cookiesProvider);
    final list = async.value;
    if (list == null) {
      return async.hasError
          ? DlmErrorState(
              title: l.list_error_title,
              message: async.error.toString(),
              retryLabel: l.list_retry,
              onRetry: () => ref.invalidate(cookiesProvider),
            )
          : DlmLoadingState(label: l.list_loading);
    }
    final gap = theme.metrics.spacing.md;
    final roots = _tree(l, list);
    return Padding(
      padding: EdgeInsets.all(theme.metrics.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.ck_intro,
            style: theme.typography.body.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          SizedBox(height: gap),
          Wrap(
            spacing: theme.metrics.spacing.sm,
            children: [
              DlmButton(
                label: l.ck_import,
                icon: const DlmIcon(DlmIconName.importIcon),
                onPressed: () => unawaited(_import()),
              ),
              DlmButton(
                label: l.ck_export,
                icon: const DlmIcon(DlmIconName.exportIcon),
                onPressed: list.isEmpty ? null : () => unawaited(_export()),
              ),
            ],
          ),
          SizedBox(height: gap),
          Expanded(
            child: list.isEmpty
                ? DlmEmptyState(
                    title: l.ck_empty_title,
                    message: l.ck_empty_message,
                  )
                : DlmTree(
                    roots: roots,
                    semanticLabel: l.ck_tree_label,
                    expandedIds: _expanded ?? const {},
                    onExpandedChanged: (ids) => setState(() => _expanded = ids),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ImportResult extends StatelessWidget {
  const _ImportResult({required this.name, required this.result});

  final String name;
  final ImportCookiesResult result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: DlmDialogContent(
        title: l.ck_import_title(name),
        message: l.ck_import_summary(result.imported, result.skipped),
        child: Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final e in result.errors ?? const <String>[])
                Padding(
                  padding: EdgeInsets.only(bottom: theme.metrics.spacing.xs),
                  child: Text(
                    e,
                    style: theme.typography.caption.copyWith(
                      color: theme.colors.danger,
                    ),
                  ),
                ),
            ],
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

/// Exports cookies as a file. The values are secrets, so the text is fetched
/// and shown only when the user presses Reveal; it can then be copied or saved.
class CookieExportDialog extends ConsumerStatefulWidget {
  /// Creates the dialog; [domain] narrows it to one domain.
  const CookieExportDialog({this.domain, super.key});

  /// The domain to export; null for all.
  final String? domain;

  @override
  ConsumerState<CookieExportDialog> createState() => _CookieExportDialogState();
}

class _CookieExportDialogState extends ConsumerState<CookieExportDialog> {
  Format _format = Format.netscape;
  ExportCookiesResult? _revealed;
  bool _busy = false;
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _reveal() async {
    setState(() => _busy = true);
    try {
      final out = await ref
          .read(cookiesProvider.notifier)
          .export(format: _format, domain: widget.domain);
      if (mounted) {
        _text.text = out.data;
        setState(() => _revealed = out);
      }
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String get _fileName =>
      'cookies${widget.domain == null ? '' : '-${widget.domain}'}'
      '.${_format == Format.valueJson ? 'json' : 'txt'}';

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    try {
      final saved = await ref.read(saveTextFileProvider)(
        _fileName,
        _revealed!.data,
      );
      if (saved && mounted) showNotice(context, ref, l.ck_saved);
    } on Object catch (e) {
      if (mounted) showFailure(context, ref, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final shown = _revealed;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 560,
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: DlmDialogContent(
        title: l.ck_export_title,
        child: Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.domain == null
                      ? l.ck_export_all
                      : l.ck_export_one(widget.domain!),
                ),
                SizedBox(height: theme.metrics.spacing.sm),
                DlmFormRow(
                  label: l.ck_format,
                  control: SizedBox(
                    width: 200,
                    child: DlmDropdown<Format>(
                      semanticLabel: l.ck_format,
                      value: _format,
                      choices: [
                        DlmChoice(
                          value: Format.netscape,
                          label: l.ck_format_netscape,
                        ),
                        DlmChoice(
                          value: Format.valueJson,
                          label: l.ck_format_json,
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        _format = v;
                        _revealed = null;
                      }),
                    ),
                  ),
                ),
                SizedBox(height: theme.metrics.spacing.sm),
                if (shown == null) ...[
                  DlmBanner(
                    tone: DlmTone.warning,
                    message: l.ck_export_warning,
                  ),
                  SizedBox(height: theme.metrics.spacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: DlmButton(
                      label: l.ck_reveal,
                      icon: const DlmIcon(DlmIconName.eye),
                      onPressed: _busy ? null : () => unawaited(_reveal()),
                    ),
                  ),
                ] else ...[
                  Text(
                    l.ck_export_count(shown.count),
                    style: theme.typography.caption.copyWith(
                      color: theme.colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: theme.metrics.spacing.xs),
                  SizedBox(
                    height: 200,
                    child: DlmTextField(
                      controller: _text,
                      semanticLabel: l.ck_export_text,
                      minLines: 8,
                      maxLines: 8,
                    ),
                  ),
                  SizedBox(height: theme.metrics.spacing.sm),
                  Wrap(
                    spacing: theme.metrics.spacing.sm,
                    children: [
                      DlmButton(
                        label: l.ck_copy,
                        icon: const DlmIcon(DlmIconName.copy),
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: shown.data),
                          );
                          if (context.mounted) {
                            showNotice(context, ref, l.ck_copied);
                          }
                        },
                      ),
                      DlmButton(
                        label: l.ck_save,
                        onPressed: () => unawaited(_save()),
                      ),
                    ],
                  ),
                ],
              ],
            ),
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
