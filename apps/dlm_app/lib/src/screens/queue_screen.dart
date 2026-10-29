import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../queues/queue_settings_dialog.dart';
import '../routing/app_routes.dart';
import '../shell/queue_commands.dart';
import 'downloads_screen.dart';

/// One queue: its state and controls above the list of its downloads.
class QueueScreen extends ConsumerWidget {
  /// Creates the page of the queue [queueId].
  const QueueScreen({required this.queueId, super.key});

  /// The queue shown.
  final String queueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final queues = ref.watch(queuesProvider);
    final list = queues.value;
    if (list == null) {
      return queues.hasError
          ? DlmErrorState(
              title: l.list_error_title,
              message: queues.error.toString(),
              retryLabel: l.list_retry,
              onRetry: () => ref.invalidate(queuesProvider),
            )
          : DlmLoadingState(label: l.list_loading);
    }
    final queue = list.where((q) => q.id == queueId).firstOrNull;
    if (queue == null) {
      return DlmEmptyState(
        title: l.queue_missing_title,
        message: l.queue_missing_message,
      );
    }
    return Column(
      children: [
        _QueueHeader(queue: queue, queues: list),
        Expanded(
          child: DownloadsScreen(
            key: ValueKey(queue.id),
            filter: DownloadsFilter.all,
            queueId: queue.id,
          ),
        ),
      ],
    );
  }
}

class _QueueHeader extends ConsumerWidget {
  const _QueueHeader({required this.queue, required this.queues});

  final Queue queue;
  final List<Queue> queues;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final running = queue.state == 'running';
    final index = queues.indexWhere((q) => q.id == queue.id);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.metrics.spacing.lg,
        vertical: theme.metrics.spacing.sm,
      ),
      child: Row(
        children: [
          DlmBadge(
            label: running ? l.queue_state_running : l.queue_state_stopped,
            tone: running ? DlmTone.success : DlmTone.neutral,
          ),
          if (queue.isDefault) ...[
            SizedBox(width: theme.metrics.spacing.sm),
            DlmBadge(label: l.queue_default, tone: DlmTone.info),
          ],
          const Spacer(),
          DlmButton(
            label: running ? l.queue_stop : l.queue_start,
            icon: DlmIcon(running ? DlmIconName.stop : DlmIconName.play),
            onPressed: () => unawaited(
              setQueueRunning(context, ref, queue, running: !running),
            ),
          ),
          SizedBox(width: theme.metrics.spacing.sm),
          DlmIconButton(
            icon: const DlmIcon(DlmIconName.settings),
            semanticLabel: l.queue_settings,
            onPressed: () => unawaited(showQueueSettings(context, ref, queue)),
          ),
          DlmMenuButton(
            icon: const DlmIcon(DlmIconName.more),
            semanticLabel: l.queue_menu,
            variant: DlmButtonVariant.plain,
            align: DlmPopoverAlign.end,
            entries: [
              DlmMenuItem(
                label: l.queue_rename,
                icon: const DlmIcon(DlmIconName.edit),
                onPressed: () => unawaited(renameQueue(context, ref, queue)),
              ),
              DlmMenuItem(
                label: l.queue_move_up,
                icon: const DlmIcon(DlmIconName.chevronUp),
                onPressed: index > 0
                    ? () => unawaited(moveQueue(context, ref, queue, -1))
                    : null,
              ),
              DlmMenuItem(
                label: l.queue_move_down,
                icon: const DlmIcon(DlmIconName.chevronDown),
                onPressed: index >= 0 && index < queues.length - 1
                    ? () => unawaited(moveQueue(context, ref, queue, 1))
                    : null,
              ),
              const DlmMenuSeparator(),
              DlmMenuItem(
                label: l.queue_delete,
                icon: const DlmIcon(DlmIconName.trash),
                destructive: true,
                onPressed: queue.isDefault
                    ? null
                    : () => unawaited(deleteQueue(context, ref, queue)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
