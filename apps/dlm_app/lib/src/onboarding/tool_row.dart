import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

/// One external program (ffmpeg, yt-dlp, the browser) and whether the daemon
/// found it.
class ToolStatusRow extends StatelessWidget {
  /// Creates the row.
  const ToolStatusRow({
    required this.label,
    required this.description,
    required this.status,
    super.key,
  });

  /// The program's name.
  final String label;

  /// What it is used for.
  final String description;

  /// What the daemon says about it; null when it did not report on it.
  final ToolStatus? status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = status;
    final (text, tone) = switch (s) {
      null => (l.setup_tool_missing, DlmTone.neutral),
      ToolStatus(available: true, :final version) => (
        version == null || version.isEmpty
            ? l.setup_tool_found_noversion
            : l.setup_tool_found(version),
        DlmTone.success,
      ),
      ToolStatus(:final error?) when error.isNotEmpty => (
        l.setup_tool_error(error),
        DlmTone.danger,
      ),
      ToolStatus(autoDownload: true) => (
        l.setup_tool_missing_auto,
        DlmTone.warning,
      ),
      _ => (l.setup_tool_missing, DlmTone.warning),
    };
    return DlmFormRow(
      label: label,
      description: description,
      control: DlmBadge(label: text, tone: tone),
    );
  }
}
