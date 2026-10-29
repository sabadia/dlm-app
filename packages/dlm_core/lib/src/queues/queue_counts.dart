import 'dart:async';

import 'package:dlm_api/dlm_api.dart';
import 'package:riverpod/riverpod.dart';

import '../providers.dart';
import '../tasks/task_status.dart';

/// How many tasks each queue holds per status, as the daemon counts them.
class QueueCountsState {
  /// Creates counts from queue id -> status -> number of tasks.
  const QueueCountsState([this.byQueue = const {}]);

  /// The raw counts.
  final Map<String, Map<String, int>> byQueue;

  /// How many tasks are in one of [statuses] (all statuses when empty), in
  /// [queueId] or in every queue.
  int count({String? queueId, Set<TaskStatus> statuses = const {}}) {
    var total = 0;
    for (final entry in byQueue.entries) {
      if (queueId != null && entry.key != queueId) continue;
      for (final status in entry.value.entries) {
        if (statuses.isEmpty || statuses.any((s) => s.wire == status.key)) {
          total += status.value;
        }
      }
    }
    return total;
  }

  /// The tasks of [queueId] that still have something to do (not finished or
  /// failed).
  int open(String queueId) {
    final all = count(queueId: queueId);
    return all -
        count(
          queueId: queueId,
          statuses: const {TaskStatus.completed, TaskStatus.error},
        );
  }
}

/// Reads the queue counts from the daemon; a seam for tests.
final queueCountsSourceProvider =
    Provider<Future<Map<String, Map<String, int>>> Function()>((ref) {
      final api = ref.watch(apiProvider);
      return () async => (await guard(api.rest.queues.listQueues)).counts;
    });

/// The per-queue counts. Read at start and again, after a short pause, each
/// time tasks appear, disappear or change status.
class QueueCounts extends Notifier<QueueCountsState> {
  Timer? _debounce;

  @override
  QueueCountsState build() {
    final store = ref.watch(taskStoreProvider);
    final sub = store.membershipChanged.listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 1), () => unawaited(refresh()));
    });
    ref.onDispose(() {
      unawaited(sub.cancel());
      _debounce?.cancel();
    });
    unawaited(Future.microtask(refresh));
    return const QueueCountsState();
  }

  /// Reads the counts again; a failure keeps the last ones.
  Future<void> refresh() async {
    try {
      final counts = await ref.read(queueCountsSourceProvider)();
      if (ref.mounted) state = QueueCountsState(counts);
    } on ApiFailure {
      // The connection banner says what is wrong.
    }
  }
}

/// The per-queue task counts.
final queueCountsProvider = NotifierProvider<QueueCounts, QueueCountsState>(
  QueueCounts.new,
);
