import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lets the user pick a folder on the daemon's machine (which may not be this
/// one), below the places the daemon allows. Returns the chosen path, or null.
Future<String?> pickDaemonFolder(BuildContext context, {String? start}) {
  final l = AppLocalizations.of(context);
  return showDlmDialog<String>(
    context,
    semanticLabel: l.folder_browser_title,
    builder: (_) => FolderBrowser(start: start),
  );
}

/// The folder browser dialog.
class FolderBrowser extends ConsumerStatefulWidget {
  /// Creates the browser, opened on [start] (the allowed roots when null).
  const FolderBrowser({this.start, super.key});

  /// The folder to open first.
  final String? start;

  @override
  ConsumerState<FolderBrowser> createState() => _FolderBrowserState();
}

class _FolderBrowserState extends ConsumerState<FolderBrowser> {
  FsListing? _listing;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_open(widget.start));
  }

  Future<void> _open(String? path) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final listing = await ref.read(addRepositoryProvider).browse(path);
      if (mounted) setState(() => _listing = listing);
    } on ApiFailure catch (e) {
      // A start that is not allowed any more: fall back to the roots.
      if (path != null && path.isNotEmpty) {
        await _open(null);
        return;
      }
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final listing = _listing;
    final atRoots = listing == null || listing.path.isEmpty;
    final Widget body;
    if (_error != null) {
      body = DlmBanner(tone: DlmTone.danger, message: l.folder_browser_error);
    } else if (listing == null) {
      body = DlmLoadingState(label: l.list_loading);
    } else {
      final entries = listing.entries ?? const <FsEntry>[];
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            atRoots ? l.folder_browser_roots : listing.path,
            style: theme.typography.caption.copyWith(
              color: theme.colors.textSecondary,
            ),
          ),
          SizedBox(height: theme.metrics.spacing.xs),
          if (!atRoots && listing.parent != null)
            DlmListRow(
              title: '..',
              leading: const DlmIcon(DlmIconName.folder),
              onTap: () => _open(listing.parent),
            ),
          for (final e in entries)
            DlmListRow(
              title: e.name,
              leading: const DlmIcon(DlmIconName.folder),
              onTap: () => _open(e.path),
            ),
          if (entries.isEmpty && !_loading)
            Padding(
              padding: EdgeInsets.all(theme.metrics.spacing.md),
              child: Text(l.folder_browser_empty),
            ),
        ],
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 480,
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: DlmDialogContent(
        title: l.folder_browser_title,
        child: Flexible(child: SingleChildScrollView(child: body)),
        actions: [
          DlmButton(
            label: l.files_cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
          DlmButton(
            label: l.folder_browser_choose,
            variant: DlmButtonVariant.primary,
            onPressed: atRoots
                ? null
                : () => Navigator.of(context).pop(listing.path),
          ),
        ],
      ),
    );
  }
}
