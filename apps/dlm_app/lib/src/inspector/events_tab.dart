import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../screens/task_format.dart';

/// What happened to a download: its current failure, and the status changes and
/// link renewals the app has seen since it connected (the daemon does not keep
/// that history itself).
class EventsTab extends ConsumerWidget {
  /// Creates the tab for the task [id].
  const EventsTab({required this.id, super.key});

  /// The task.
  final String id;

  String _status(AppLocalizations l, String? wire) =>
      wire == null ? '' : statusLabel(l, TaskStatus.parse(wire));

  String _describe(AppLocalizations l, TaskLogEntry e) => switch (e.kind) {
    TaskLogKind.created => l.ev_created,
    TaskLogKind.status => l.ev_status(_status(l, e.from), _status(l, e.to)),
    TaskLogKind.refresh => l.ev_refresh(e.strategy ?? '', e.outcome ?? ''),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final task = ref.watch(taskProvider(id));
    final entries = ref.watch(taskLogProvider(id)).reversed.toList();
    final time = DateFormat.yMd(l.localeName).add_Hms();
    final error = task?.error;
    return ListView(
      padding: EdgeInsets.all(theme.metrics.spacing.md),
      children: [
        if (error != null)
          Padding(
            padding: EdgeInsets.only(bottom: theme.metrics.spacing.md),
            child: DlmBanner(
              tone: DlmTone.danger,
              title: l.ev_current_error,
              message:
                  '${error.message} (${error.code}) · '
                  '${time.format(error.at.toLocal())}',
            ),
          ),
        if (entries.isEmpty)
          Text(
            l.ev_none,
            style: theme.typography.caption.copyWith(
              color: theme.colors.textSecondary,
            ),
          )
        else
          for (final e in entries)
            Padding(
              padding: EdgeInsets.symmetric(vertical: theme.metrics.spacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DlmIcon(
                    e.isFailure ? DlmIconName.error : DlmIconName.info,
                    color: e.isFailure
                        ? theme.colors.danger
                        : theme.colors.textSecondary,
                  ),
                  SizedBox(width: theme.metrics.spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_describe(l, e)),
                        Text(
                          [
                            time.format(e.time.toLocal()),
                            if (e.errorMessage != null) e.errorMessage!,
                          ].join(' · '),
                          style: theme.typography.caption.copyWith(
                            color: e.isFailure
                                ? theme.colors.danger
                                : theme.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        SizedBox(height: theme.metrics.spacing.md),
        Text(
          l.ev_note,
          style: theme.typography.caption.copyWith(
            color: theme.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
