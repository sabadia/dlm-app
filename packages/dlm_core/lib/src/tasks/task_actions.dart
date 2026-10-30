import 'package:dlm_api/dlm_api.dart';

import 'task_repository.dart';
import 'task_status.dart';
import 'task_store.dart';

/// Commands on tasks, applied to the UI immediately and undone when the
/// daemon refuses (optimistic updates with rollback).
///
/// Every method returns the per-task [ItemResult]s so the caller can show what
/// failed; a failure of the whole call (daemon unreachable) is thrown after
/// the rollback. The daemon's events then confirm or correct the state.
class TaskActions {
  /// Creates the commands.
  TaskActions(this._repo, this._store);

  final TaskRepository _repo;
  final TaskStore _store;

  /// Puts [next] in the cache for [id] as the guess of a command in flight.
  Task _guess(String id, Task next) {
    _store.tasks.put(id, next);
    return next;
  }

  /// Puts [before] back, unless the cache moved on since the guess was made:
  /// an event that arrived while the request was out (the task completed, say)
  /// is newer than the state before the command and must stay.
  void _undo(String id, Task before, Task? guess) {
    if (guess == null || identical(_store.tasks[id], guess)) {
      _store.tasks.put(id, before);
    }
  }

  /// Pauses the tasks that can be paused.
  Future<List<ItemResult>> pause(List<String> ids) => _bulk(
    ids,
    optimistic: (t) =>
        t.statusKind.canPause ? t.copyWith(status: 'paused') : null,
    call: _repo.pause,
  );

  /// Resumes the tasks that can be resumed.
  Future<List<ItemResult>> resume(List<String> ids) => _bulk(
    ids,
    optimistic: (t) => t.statusKind.canResume
        ? t.copyWith(status: 'queued', clearError: true)
        : null,
    call: _repo.resume,
  );

  /// Deletes tasks; they disappear from the lists at once.
  Future<List<ItemResult>> delete(
    List<String> ids, {
    bool files = false,
  }) async {
    final removed = <String, Task>{};
    for (final id in ids) {
      final t = _store.tasks.remove(id);
      if (t != null) removed[id] = t;
    }
    try {
      final results = await _repo.delete(ids, files: files);
      for (final r in results.where((r) => !r.ok)) {
        final t = removed[r.id];
        if (t != null && _store.tasks[r.id] == null) _store.tasks.put(r.id, t);
      }
      return results;
    } on Object {
      removed.forEach((id, t) {
        if (_store.tasks[id] == null) _store.tasks.put(id, t);
      });
      rethrow;
    }
  }

  /// Restarts one task.
  Future<Task> restart(String id) => _single(
    id,
    optimistic: (t) =>
        t.copyWith(status: 'queued', clearError: true, downloaded: 0),
    call: () => _repo.restart(id),
  );

  /// Pauses every task that can be paused, on the daemon's whole list.
  Future<List<ItemResult>> pauseAll() async {
    final before = <String, Task>{};
    final guesses = <String, Task>{};
    for (final id in _store.tasks.ids) {
      final t = _store.tasks[id];
      if (t != null && t.statusKind.canPause) {
        before[id] = t;
        guesses[id] = _guess(id, t.copyWith(status: 'paused'));
      }
    }
    try {
      return await _repo.pauseAll();
    } on Object {
      before.forEach((id, t) => _undo(id, t, guesses[id]));
      rethrow;
    }
  }

  /// Resumes every paused task, on the daemon's whole list.
  Future<List<ItemResult>> resumeAll() async {
    final before = <String, Task>{};
    final guesses = <String, Task>{};
    for (final id in _store.tasks.ids) {
      final t = _store.tasks[id];
      if (t != null && t.statusKind == TaskStatus.paused) {
        before[id] = t;
        guesses[id] = _guess(
          id,
          t.copyWith(status: 'queued', clearError: true),
        );
      }
    }
    try {
      return await _repo.resumeAll();
    } on Object {
      before.forEach((id, t) => _undo(id, t, guesses[id]));
      rethrow;
    }
  }

  /// Restarts the finished or failed tasks among [ids] from the beginning.
  Future<List<ItemResult>> restartMany(List<String> ids) => _bulk(
    ids,
    optimistic: (t) => t.statusKind.isFinished
        ? t.copyWith(status: 'queued', clearError: true, downloaded: 0)
        : null,
    call: _repo.restartMany,
  );

  /// Asks for a fresh link for [ids].
  Future<List<ItemResult>> refreshMany(List<String> ids) =>
      _bulk(ids, optimistic: (_) => null, call: _repo.refreshMany);

  /// Moves [ids] to the end of [queueId].
  Future<List<ItemResult>> moveMany(List<String> ids, String queueId) => _bulk(
    ids,
    optimistic: (t) =>
        t.queueId == queueId ? null : t.copyWith(queueId: queueId),
    call: (ids) => _repo.moveMany(ids, queueId),
  );

  /// Gives [ids] a priority.
  Future<List<ItemResult>> prioritise(
    List<String> ids,
    UpdateTasksBodyPriority priority,
  ) => _bulk(
    ids,
    optimistic: (t) => t.priority == priority.json
        ? null
        : t.copyWith(priority: priority.json),
    call: (ids) => _repo.prioritise(ids, priority),
  );

  /// Moves a task to [queueId].
  Future<Task> move(String id, String queueId) =>
      _single(id, optimistic: (t) => t, call: () => _repo.move(id, queueId));

  /// Moves a task to [position] in its queue.
  Future<Task> reorder(String id, int position) => _single(
    id,
    optimistic: (t) => t.copyWith(position: position),
    call: () => _repo.reorder(id, position),
  );

  Future<List<ItemResult>> _bulk(
    List<String> ids, {
    required Task? Function(Task) optimistic,
    required Future<List<ItemResult>> Function(List<String>) call,
  }) async {
    final before = <String, Task>{};
    final guesses = <String, Task>{};
    for (final id in ids) {
      final t = _store.tasks[id];
      if (t == null) continue;
      final next = optimistic(t);
      if (next == null) continue;
      before[id] = t;
      guesses[id] = _guess(id, next);
    }
    try {
      final results = await call(ids);
      for (final r in results) {
        final t = r.task;
        if (r.ok && t != null) {
          _store.tasks.put(r.id, t);
        } else if (!r.ok && before.containsKey(r.id)) {
          _undo(r.id, before[r.id]!, guesses[r.id]);
        }
      }
      return results;
    } on Object {
      before.forEach((id, t) => _undo(id, t, guesses[id]));
      rethrow;
    }
  }

  Future<Task> _single(
    String id, {
    required Task Function(Task) optimistic,
    required Future<Task> Function() call,
  }) async {
    final before = _store.tasks[id];
    final guess = before == null ? null : _guess(id, optimistic(before));
    try {
      final after = await call();
      _store.tasks.put(id, after);
      return after;
    } on Object {
      if (before != null) _undo(id, before, guess);
      rethrow;
    }
  }
}
