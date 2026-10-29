import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';
import 'package:dlm_l10n/dlm_l10n.dart';
import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shell/feedback.dart';
import '../shell/queue_commands.dart';

/// The time of day; replaced in tests so the countdown follows fake time.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// What a queue will do once its grace period is over.
class PendingQueueAction {
  /// Creates a pending action.
  const PendingQueueAction({
    required this.queueId,
    required this.action,
    required this.deadline,
  });

  /// The queue that finished.
  final String queueId;

  /// `stop`, `sleep`, `shutdown` or `command`.
  final String action;

  /// When it runs, on this computer's clock.
  final DateTime deadline;
}

/// The post-queue actions waiting for their grace period to end, by queue.
///
/// The daemon announces them with `queue.completed` and withdraws them with
/// `queue.action_cancelled` (new work, queue stopped or deleted, settings
/// changed). The time left is measured from the moment the event arrived so a
/// remote daemon with a different clock still counts down correctly.
class PendingQueueActions extends Notifier<Map<String, PendingQueueAction>> {
  @override
  Map<String, PendingQueueAction> build() {
    final sub = ref.watch(syncEngineProvider).events.listen(_onEvent);
    ref.onDispose(sub.cancel);
    return const {};
  }

  void _onEvent(StreamEvent event) {
    switch (event) {
      case StreamEventQueueCompletedEvent(
        :final queueId,
        :final data,
        :final time,
      ):
        if (queueId == null) return;
        final grace = data.executeAt.difference(time);
        state = {
          ...state,
          queueId: PendingQueueAction(
            queueId: queueId,
            action: data.action,
            deadline: ref
                .read(clockProvider)()
                .add(grace.isNegative ? Duration.zero : grace),
          ),
        };
      case StreamEventQueueActionCancelledEvent(:final queueId):
        _drop(queueId);
      case StreamEventQueueDeletedEvent(:final data):
        _drop(data.id);
      default:
        break;
    }
  }

  void _drop(String? queueId) {
    if (queueId == null || !state.containsKey(queueId)) return;
    state = {...state}..remove(queueId);
  }

  /// Forgets an action whose time has come (the daemon runs it itself).
  void expire(String queueId) => _drop(queueId);
}

/// The pending post-queue actions.
final pendingQueueActionsProvider =
    NotifierProvider<PendingQueueActions, Map<String, PendingQueueAction>>(
      PendingQueueActions.new,
    );

/// Queue ids whose action the daemon cancelled.
final queueActionCancelledProvider = StreamProvider<String>(
  (ref) => ref
      .watch(syncEngineProvider)
      .events
      .where((e) => e is StreamEventQueueActionCancelledEvent)
      .map((e) => (e as StreamEventQueueActionCancelledEvent).queueId)
      .where((id) => id != null)
      .cast<String>(),
);

/// A banner per finished queue that is about to do something to the computer,
/// with the seconds left and a button that cancels it. The daemon cancels an
/// action when its queue is stopped, so the button stops the queue.
class QueueCountdownBanners extends ConsumerStatefulWidget {
  /// Creates the banner area.
  const QueueCountdownBanners({super.key});

  @override
  ConsumerState<QueueCountdownBanners> createState() =>
      _QueueCountdownBannersState();
}

class _QueueCountdownBannersState extends ConsumerState<QueueCountdownBanners> {
  Timer? _tick;

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _actionText(AppLocalizations l, String action) => switch (action) {
    'sleep' => l.qs_after_sleep,
    'shutdown' => l.qs_after_shutdown,
    'command' => l.qs_after_command,
    _ => l.qs_after_stop,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = DlmTheme.of(context);
    final controller = ref.read(pendingQueueActionsProvider.notifier);
    final clock = ref.watch(clockProvider);
    final pending = ref.watch(pendingQueueActionsProvider);
    final queues = ref.watch(queuesProvider).value ?? const <Queue>[];

    ref.listen(queueActionCancelledProvider, (_, next) {
      final id = next.value;
      if (id == null) return;
      final name = queues.where((q) => q.id == id).firstOrNull?.name;
      if (name != null) {
        showNotice(context, ref, l.queue_action_cancelled(name));
      }
    });

    if (pending.isEmpty) {
      _tick?.cancel();
      _tick = null;
      return const SizedBox.shrink();
    }
    _tick ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final now = clock();
      for (final p in ref.read(pendingQueueActionsProvider).values) {
        if (!p.deadline.isAfter(now)) controller.expire(p.queueId);
      }
      setState(() {});
    });

    final now = clock();
    return Padding(
      padding: EdgeInsets.all(theme.metrics.spacing.md),
      child: Column(
        children: [
          for (final p in pending.values)
            DlmBanner(
              tone: DlmTone.warning,
              title: l.queue_countdown_title(
                queues.where((q) => q.id == p.queueId).firstOrNull?.name ??
                    p.queueId,
              ),
              message: l.queue_countdown_message(
                _actionText(l, p.action),
                formatDuration(
                  p.deadline.isAfter(now)
                      ? p.deadline.difference(now)
                      : Duration.zero,
                ),
              ),
              actionLabel: l.queue_countdown_cancel,
              onAction: () {
                final queue = queues
                    .where((q) => q.id == p.queueId)
                    .firstOrNull;
                if (queue != null) {
                  unawaited(
                    setQueueRunning(context, ref, queue, running: false),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
