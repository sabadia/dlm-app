import 'dart:async';

import 'package:dlm_api/dlm_api.dart';

import '../stores/entity_store.dart';
import 'task_log.dart';
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
  final _speed = StreamController<SpeedData>.broadcast(sync: true);
  final _limits = StreamController<void>.broadcast(sync: true);
  final _log = <String, List<TaskLogEntry>>{};
  final _logChanged = StreamController<String>.broadcast(sync: true);
  final _resources = StreamController<ResourceChangedData>.broadcast(
    sync: true,
  );

  /// The latest total speed and counts the daemon reported, or null before the
  /// first report.
  SpeedData? speed;

  /// What the app has seen happen to the task [id], oldest first. The daemon
  /// keeps no such history: it starts when the app connects.
  List<TaskLogEntry> logOf(String id) =>
      List.unmodifiable(_log[id] ?? const []);

  /// Fires with the id of a task whose log grew.
  Stream<String> get logChanged => _logChanged.stream;

  void _record(String id, TaskLogEntry entry) {
    final list = _log.putIfAbsent(id, () => [])..add(entry);
    if (list.length > taskLogLimit) list.removeAt(0);
    _logChanged.add(id);
  }

  /// Fires with each `system.speed` report (about once a second).
  Stream<SpeedData> get speedChanged => _speed.stream;

  /// Fires when somebody else created, changed or deleted a category, webhook,
  /// credential, cookie, plugin or the boot config (`resource.changed`):
  /// whoever shows that kind reads it again.
  Stream<ResourceChangedData> get resourceChanged => _resources.stream;

  /// Fires when the speed limits or a quota changed (`limits.changed`,
  /// `quota.exhausted`, `quota.reset`): whoever shows them reads them again.
  Stream<void> get limitsChanged => _limits.stream;

  /// Fires when tasks appeared, disappeared or moved between statuses, that
  /// is when a list showing a filtered window of tasks may be out of date.
  Stream<void> get membershipChanged => _membership.stream;

  /// Applies one daemon event.
  void apply(StreamEvent event) {
    switch (event) {
      case StreamEventTaskCreatedEvent(:final data, :final time):
        tasks.put(data.id, data);
        _record(data.id, TaskLogEntry(time: time, kind: TaskLogKind.created));
        _membership.add(null);
      case StreamEventTaskUpdatedEvent(:final data):
        tasks.put(data.id, data);
        _membership.add(null);
      case StreamEventTaskStatusEvent(:final taskId, :final data, :final time):
        final id = taskId;
        if (id == null) return;
        _record(
          id,
          TaskLogEntry(
            time: time,
            kind: TaskLogKind.status,
            from: data.from,
            to: data.to,
            errorCode: data.error?.code,
            errorMessage: data.error?.message,
          ),
        );
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
      case StreamEventSystemSpeedEvent(:final data):
        speed = data;
        _speed.add(data);
      case StreamEventTaskRefreshEvent(:final taskId, :final data, :final time):
        if (taskId != null) {
          _record(
            taskId,
            TaskLogEntry(
              time: time,
              kind: TaskLogKind.refresh,
              strategy: data.strategy,
              outcome: data.outcome,
              errorMessage: data.error,
            ),
          );
        }
      case StreamEventResourceChangedEvent(:final data):
        _resources.add(data);
      case StreamEventLimitsChangedEvent() ||
          StreamEventQuotaExhaustedEvent() ||
          StreamEventQuotaResetEvent():
        _limits.add(null);
      default:
        break; // refresh, settings and queue completion are not entities
    }
  }

  /// Empties the caches (after a stream reset, before refetching).
  void clear() {
    tasks.clear();
    progress.clear();
    queues.clear();
    speed = null;
    _log.clear();
    _limits.add(null);
  }

  /// Releases the streams.
  Future<void> dispose() async {
    await _membership.close();
    await _speed.close();
    await _limits.close();
    await _resources.close();
    await _logChanged.close();
  }
}
