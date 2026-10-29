import 'package:dlm_api/dlm_api.dart';
import 'package:dlm_core/dlm_core.dart';

Task task(
  String id, {
  String status = 'queued',
  int position = 0,
  int size = 100,
  int downloaded = 0,
  String queueId = 'main',
}) => Task(
  createdAt: DateTime.utc(2026, 10, 29),
  downloaded: downloaded,
  id: id,
  position: position,
  priority: 'normal',
  queueId: queueId,
  settings: const Settings(),
  size: size,
  source: const Source(
    currentUrl: 'http://x/f',
    fingerprint: Fingerprint(size: -1),
  ),
  status: status,
  updatedAt: DateTime.utc(2026, 10, 29),
  name: id,
);

ProgressData progress(int downloaded, {int size = 100}) =>
    ProgressData(connections: 2, downloaded: downloaded, size: size, speed: 10);

/// A scripted daemon for the task layer.
class FakeTaskRepository implements TaskRepository {
  /// Tasks the daemon holds, in list order.
  final tasks = <Task>[];
  final calls = <String>[];
  int pageSize = 2;
  Object? failNext;
  final failIds = <String>{};

  void _maybeFail() {
    final f = failNext;
    if (f != null) {
      failNext = null;
      // ignore: only_throw_errors
      throw f;
    }
  }

  @override
  Future<TaskPage> list(
    TaskQuery query, {
    String? cursor,
    int limit = 50,
  }) async {
    calls.add('list:${cursor ?? ''}:$limit');
    _maybeFail();
    final matching = [
      for (final t in tasks)
        if (query.queueId == null || t.queueId == query.queueId)
          if (query.statuses.isEmpty || query.statuses.contains(t.statusKind))
            t,
    ];
    final start = cursor == null ? 0 : int.parse(cursor);
    final end = (start + pageSize).clamp(0, matching.length);
    return TaskPage(
      matching.sublist(start, end),
      end < matching.length ? '$end' : null,
    );
  }

  @override
  Future<Task> get(String id) async => tasks.firstWhere((t) => t.id == id);

  List<ItemResult> _results(List<String> ids, String status) => [
    for (final id in ids)
      if (failIds.contains(id))
        ItemResult(
          id: id,
          ok: false,
          error: const ApiProblem(status: 409, code: 'task.invalid_state'),
        )
      else
        ItemResult(
          id: id,
          ok: true,
          task: task(id, status: status),
        ),
  ];

  @override
  Future<List<ItemResult>> pause(List<String> ids) async {
    calls.add('pause:${ids.join(',')}');
    _maybeFail();
    return _results(ids, 'paused');
  }

  @override
  Future<List<ItemResult>> resume(List<String> ids) async {
    calls.add('resume:${ids.join(',')}');
    _maybeFail();
    return _results(ids, 'queued');
  }

  @override
  Future<List<ItemResult>> delete(
    List<String> ids, {
    bool files = false,
  }) async {
    calls.add('delete:${ids.join(',')}:$files');
    _maybeFail();
    return [
      for (final id in ids)
        ItemResult(
          id: id,
          ok: !failIds.contains(id),
          error: failIds.contains(id)
              ? const ApiProblem(status: 409, code: 'task.locked')
              : null,
        ),
    ];
  }

  @override
  Future<Task> restart(String id) async {
    calls.add('restart:$id');
    _maybeFail();
    return task(id);
  }

  @override
  Future<Task> move(String id, String queueId) async {
    calls.add('move:$id:$queueId');
    _maybeFail();
    return task(id, queueId: queueId);
  }

  @override
  Future<Task> reorder(String id, int position) async {
    calls.add('reorder:$id:$position');
    _maybeFail();
    return task(id, position: position);
  }

  @override
  Future<List<ItemResult>> restartMany(List<String> ids) async {
    calls.add('restartMany:${ids.join(',')}');
    return [for (final id in ids) ItemResult(id: id, ok: true)];
  }

  @override
  Future<List<ItemResult>> refreshMany(List<String> ids) async {
    calls.add('refreshMany:${ids.join(',')}');
    return [for (final id in ids) ItemResult(id: id, ok: true)];
  }

  @override
  Future<List<ItemResult>> moveMany(List<String> ids, String queueId) async {
    calls.add('moveMany:${ids.join(',')}:$queueId');
    return [for (final id in ids) ItemResult(id: id, ok: true)];
  }

  @override
  Future<List<ItemResult>> prioritise(
    List<String> ids,
    UpdateTasksBodyPriority priority,
  ) async {
    calls.add('prioritise:${ids.join(',')}:${priority.json}');
    return [for (final id in ids) ItemResult(id: id, ok: true)];
  }

  @override
  Future<Task> update(
    String id, {
    String? name,
    String? dir,
    UpdateTaskBodyPriority? priority,
  }) async => task(id);
}
