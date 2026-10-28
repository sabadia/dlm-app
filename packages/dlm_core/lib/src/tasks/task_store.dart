import 'dart:async';

import 'package:dlm_api/dlm_api.dart';

import '../stores/entity_store.dart';
import 'task_status.dart';

/// The cached tasks, their live progress and the queues, patched by the
/// daemon's events.
///
/// Progress (speed, connections) lives apart from the task: it changes many
/// times a second, and only the row that shows it should wake up.
class TaskStore {
  /// The tasks by id.
  final tasks = EntityStore<Task>();

  /// The latest progress of running tasks by id.
  final progress = EntityStore<ProgressData>();

  /// The queues by id.
  final queues = EntityStore<Queue>();

  final _membership = StreamController<void>.broadcast(sync: true);

  /// Fires when tasks appeared, disappeared or moved between statuses, that
  /// is when a list showing a filtered window of tasks may be out of date.
  Stream<void> get membershipChanged => _membership.stream;

  /// Applies one daemon event.
  void apply(StreamEvent event) {
    switch (event) {
      case StreamEventTaskCreatedEvent(:final data):
        tasks.put(data.id, data);
        _membership.add(null);
      case StreamEventTaskUpdatedEvent(:final data):
        tasks.put(data.id, data);
        _membership.add(null);
      case StreamEventTaskStatusEvent(:final taskId, :final data, :final time):
        final id = taskId;
        if (id == null) return;
        final current = tasks[id];
        if (current != null) {
          final done = TaskStatus.parse(data.to) == TaskStatus.completed;
          tasks.put(
            id,
            current.copyWith(
              status: data.to,
              error: data.error,
              clearError: data.error == null,
              updatedAt: time,
              completedAt: done ? time : null,
              downloaded: done && current.size >= 0 ? current.size : null,
            ),
          );
        }
        if (!TaskStatus.parse(data.to).isActive) progress.remove(id);
        _membership.add(null);
      case StreamEventTaskProgressEvent(:final taskId, :final data):
        final id = taskId;
        if (id != null) progress.put(id, data);
      case StreamEventTaskDeletedEvent(:final data):
        tasks.remove(data.id);
        progress.remove(data.id);
        _membership.add(null);
      case StreamEventQueueCreatedEvent(:final data):
        queues.put(data.id, data);
      case StreamEventQueueUpdatedEvent(:final data):
        queues.put(data.id, data);
      case StreamEventQueueDeletedEvent(:final data):
        queues.remove(data.id);
      default:
        break; // refresh, quota, settings and queue completion are not entities
    }
  }

  /// Empties the caches (after a stream reset, before refetching).
  void clear() {
    tasks.clear();
    progress.clear();
    queues.clear();
  }

  /// Releases the stream.
  Future<void> dispose() => _membership.close();
}
