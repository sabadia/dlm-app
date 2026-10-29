import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../format/dlm_format.dart';

/// Status, progress, destination, times and the last error of one download.
class OverviewTab extends ConsumerWidget {
  /// Creates the tab for the task [id].
  const OverviewTab({required this.id, super.key});

  /// The task.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final task = ref.watch(taskProvider(id));
    final progress = ref.watch(taskProgressProvider(id));
    if (task == null) return const SizedBox.shrink();

    final downloaded = progress?.downloaded ?? task.downloaded;
    final size = progress?.size ?? task.size;
    final finished = task.statusKind == TaskStatus.completed;
    final fraction = size > 0 ? (downloaded / size).clamp(0.0, 1.0) : null;
    final running = task.statusKind.isActive && progress != null;
    final left = running
        ? estimateRemaining(
            downloaded: progress.downloaded,
            size: progress.size,
            bytesPerSecond: progress.speed,
          )
        : null;
    final queueName = ref.watch(queueProvider(task.queueId))?.name;
    String when(DateTime t) =>
        DateFormat.yMMMd(l.localeName).add_Hm().format(t.toLocal());
    final labels = task.labels?.entries.map((e) => '${e.key}=${e.value}');

    return ListView(
      padding: EdgeInsets.all(theme.metrics.spacing.md),
      children: [
        if (task.error case final TaskError error?) ...[
          DlmBanner(
            tone: DlmTone.danger,
            title: l.ov_error_title,
            message:
                '${l.ov_error_detail(error.message, error.code)}\n'
                '${when(error.at)} · '
                '${error.retryable ? l.ov_error_retryable : l.ov_error_final}',
          ),
          SizedBox(height: theme.metrics.spacing.md),
        ],
        DlmFormGroup(
          title: l.ov_group_progress,
          children: [
            DlmFormRow(
              label: l.ov_progress,
              control: SizedBox(
                width: 160,
                child: DlmProgressBar(
                  value: finished ? 1 : fraction,
                  tone: switch (task.statusKind) {
                    TaskStatus.completed => DlmTone.success,
                    TaskStatus.error => DlmTone.danger,
                    _ => DlmTone.accent,
                  },
                  semanticLabel: l.ov_progress,
                ),
              ),
            ),
            _row(l.ov_size, context.bytes(size) ?? l.ov_size_unknown, l),
            _row(l.ov_downloaded, context.bytes(downloaded) ?? l.ov_none, l),
            if (running) ...[
              _row(l.ov_speed, context.speed(progress.speed) ?? l.ov_none, l),
              _row(
                l.ov_time_left,
                left == null ? l.ov_none : formatDuration(left),
                l,
              ),
              _row(l.ov_connections, '${progress.connections}', l),
            ],
          ],
        ),
        SizedBox(height: theme.metrics.spacing.md),
        DlmFormGroup(
          title: l.ov_group_where,
          children: [
            _row(l.ov_queue, queueName ?? task.queueId, l),
            _row(l.ov_engine, task.engine ?? l.ov_none, l),
            _row(l.ov_folder, task.dir ?? l.ov_none, l),
            _row(l.ov_priority, _priority(l, task.priority), l),
            if (labels != null && labels.isNotEmpty)
              _row(l.ov_labels, labels.join(', '), l),
          ],
        ),
        SizedBox(height: theme.metrics.spacing.md),
        DlmFormGroup(
          title: l.ov_group_times,
          children: [
            _row(l.ov_added, when(task.createdAt), l),
            if (task.startedAt != null)
              _row(l.ov_started, when(task.startedAt!), l),
            if (task.completedAt != null)
              _row(l.ov_completed, when(task.completedAt!), l),
          ],
        ),
      ],
    );
  }

  static String _priority(AppLocalizations l, String p) => switch (p) {
    'low' => l.ov_priority_low,
    'normal' => l.ov_priority_normal,
    'high' => l.ov_priority_high,
    _ => p,
  };

  static Widget _row(String label, String value, AppLocalizations l) =>
      DlmFormRow(
        label: label,
        control: Text(value, textAlign: TextAlign.end),
      );
}
