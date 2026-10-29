import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// What the daemon said about one link of a batch, in words.
String resultReason(AppLocalizations l, BatchItem item) {
  final error = item.error;
  if (item.ok) return l.add_result_ok;
  if (error == null) return l.add_result_failed;
  if (error.code == 'task.duplicate') return l.add_result_duplicate;
  final detail = error.detail ?? error.title;
  return detail == null || detail.isEmpty ? error.code : detail;
}

/// Shows what happened to each link of a batch: added, or why not. With
/// [confirmLabel] the sheet is a preview that asks whether to go ahead; the
/// answer is true when confirmed.
Future<bool> showAddResults(
  BuildContext context, {
  required String title,
  required List<BatchItem> results,
  String? confirmLabel,
}) async {
  final answer = await showDlmDialog<bool>(
    context,
    semanticLabel: title,
    builder: (_) => AddResultsSheet(
      title: title,
      results: results,
      confirmLabel: confirmLabel,
    ),
  );
  return answer ?? false;
}

/// The content of the result sheet.
class AddResultsSheet extends StatelessWidget {
  /// Creates the sheet.
  const AddResultsSheet({
    required this.title,
    required this.results,
    this.confirmLabel,
    super.key,
  });

  /// The heading.
  final String title;

  /// One entry per link.
  final List<BatchItem> results;

  /// Label of the button that goes ahead; null for a plain report.
  final String? confirmLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final ok = results.where((r) => r.ok).length;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 560,
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: DlmDialogContent(
        title: title,
        message: l.add_results_summary(ok, results.length - ok),
        child: Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final r in results)
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: theme.metrics.spacing.xs,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DlmIcon(
                        r.ok ? DlmIconName.success : DlmIconName.error,
                        color: r.ok
                            ? theme.colors.success
                            : theme.colors.danger,
                      ),
                      SizedBox(width: theme.metrics.spacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.url ?? r.task?.name ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              resultReason(l, r),
                              style: theme.typography.caption.copyWith(
                                color: theme.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          DlmButton(
            label: confirmLabel == null ? l.add_close : l.files_cancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          if (confirmLabel != null)
            DlmButton(
              label: confirmLabel!,
              variant: DlmButtonVariant.primary,
              onPressed: ok > 0 ? () => Navigator.of(context).pop(true) : null,
            ),
        ],
      ),
    );
  }
}
