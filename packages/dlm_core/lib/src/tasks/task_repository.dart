import 'package:dlm_api/dlm_api.dart';

import 'task_status.dart';

/// Which tasks a list shows.
class TaskQuery {
  /// Creates a query.
  const TaskQuery({
    this.queueId,
    this.statuses = const {},
    this.text,
    this.sort = Sort.position,
    this.order,
    this.engine,
    this.category,
    this.label,
  });

  /// Only tasks of this queue.
  final String? queueId;

  /// Only tasks in one of these statuses; empty means all.
  final Set<TaskStatus> statuses;

  /// Text to find in the name or URL.
  final String? text;

  /// The sort key.
  final Sort sort;

  /// The direction; null is the key's natural one.
  final Order? order;

  /// Only tasks of this engine (`http`, `bt`, ...).
  final String? engine;

  /// Only tasks of this category (id or name).
  final String? category;

  /// Only tasks with this label (`key` or `key=value`).
  final String? label;

  @override
  bool operator ==(Object other) =>
      other is TaskQuery &&
      other.queueId == queueId &&
      other.text == text &&
      other.sort == sort &&
      other.order == order &&
      other.engine == engine &&
      other.category == category &&
      other.label == label &&
      other.statuses.length == statuses.length &&
      other.statuses.containsAll(statuses);

  @override
  int get hashCode => Object.hash(
    queueId,
    text,
    sort,
    order,
    engine,
    category,
    label,
    Object.hashAllUnordered(statuses),
  );
}

/// One page of tasks.
class TaskPage {
  /// Creates a page.
  const TaskPage(this.tasks, this.nextCursor, {this.total});

  /// The tasks, in the query's order.
  final List<Task> tasks;

  /// Pass to the next call for the following page; null at the end.
  final String? nextCursor;

  /// How many tasks match the query in all; only on the first page.
  final int? total;
}

/// The outcome of a bulk operation for one task.
class ItemResult {
  /// Creates a result.
  const ItemResult({required this.id, required this.ok, this.task, this.error});

  /// The task.
  final String id;

  /// Whether the daemon did it.
  final bool ok;

  /// The task after the operation.
  final Task? task;

  /// Why not.
  final ApiProblem? error;
}

/// What the app asks of the daemon about tasks.
abstract interface class TaskRepository {
  /// One page of tasks.
  Future<TaskPage> list(TaskQuery query, {String? cursor, int limit = 50});

  /// One task.
  Future<Task> get(String id);

  /// Pauses [ids].
  Future<List<ItemResult>> pause(List<String> ids);

  /// Resumes [ids].
  Future<List<ItemResult>> resume(List<String> ids);

  /// Deletes [ids], with their files when [files].
  Future<List<ItemResult>> delete(List<String> ids, {bool files = false});

  /// Restarts a failed or finished task from the beginning.
  Future<Task> restart(String id);

  /// Restarts several tasks from the beginning.
  Future<List<ItemResult>> restartMany(List<String> ids);

  /// Asks for a fresh link for several tasks (those that can renew theirs).
  Future<List<ItemResult>> refreshMany(List<String> ids);

  /// Pauses everything that is queued or running, whichever tasks the app has
  /// loaded.
  Future<List<ItemResult>> pauseAll();

  /// Resumes everything that is paused.
  Future<List<ItemResult>> resumeAll();

  /// Moves several tasks to the end of another queue.
  Future<List<ItemResult>> moveMany(List<String> ids, String queueId);

  /// Gives several tasks a priority.
  Future<List<ItemResult>> prioritise(
    List<String> ids,
    UpdateTasksBodyPriority priority,
  );

  /// Moves a task to another queue.
  Future<Task> move(String id, String queueId);

  /// Puts a task at [position] in its queue.
  Future<Task> reorder(String id, int position);

  /// Renames or re-prioritises a task.
  Future<Task> update(
    String id, {
    String? name,
    String? dir,
    UpdateTaskBodyPriority? priority,
  });
}

/// [TaskRepository] over the generated client.
class ApiTaskRepository implements TaskRepository {
  /// Creates the repository.
  ApiTaskRepository(this._api);

  final DlmApi _api;

  TasksClient get _tasks => _api.rest.tasks;

  @override
  Future<TaskPage> list(TaskQuery query, {String? cursor, int limit = 50}) {
    return guard(() async {
      final page = await _tasks.listTasks(
        sort: query.sort,
        order: query.order,
        engine: query.engine,
        category: query.category,
        label: query.label,
        // The count is asked for once, with the first page.
        total: cursor == null ? true : null,
        limit: limit,
        queueId: query.queueId,
        status: [
          for (final s in query.statuses)
            ...Status.values.where((v) => v.json == s.wire),
        ],
        q: query.text,
        cursor: cursor,
      );
      return TaskPage(
        page.tasks ?? const [],
        page.nextCursor,
        total: page.total,
      );
    });
  }

  @override
  Future<Task> get(String id) => guard(() => _tasks.getTask(id: id));

  @override
  Future<List<ItemResult>> pause(List<String> ids) => guard(
    () async => _items(await _tasks.pauseTasks(body: TaskSelector(ids: ids))),
  );

  @override
  Future<List<ItemResult>> resume(List<String> ids) => guard(
    () async => _items(await _tasks.resumeTasks(body: TaskSelector(ids: ids))),
  );

  @override
  Future<List<ItemResult>> delete(List<String> ids, {bool files = false}) =>
      guard(
        () async => _items(
          await _tasks.deleteTasks(
            body: DeleteTasksBody(ids: ids, files: files),
          ),
        ),
      );

  @override
  Future<Task> restart(String id) => guard(() => _tasks.restartTask(id: id));

  @override
  Future<List<ItemResult>> pauseAll() => guard(
    () async => _items(
      await _tasks.pauseTasks(
        body: const TaskSelector(
          filter: TaskSelectorFilter(
            status: [
              TaskSelectorFilterStatus.queued,
              TaskSelectorFilterStatus.running,
              TaskSelectorFilterStatus.refreshing,
              TaskSelectorFilterStatus.awaitingLink,
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Future<List<ItemResult>> resumeAll() => guard(
    () async => _items(
      await _tasks.resumeTasks(
        body: const TaskSelector(
          filter: TaskSelectorFilter(status: [TaskSelectorFilterStatus.paused]),
        ),
      ),
    ),
  );

  @override
  Future<List<ItemResult>> restartMany(List<String> ids) => guard(
    () async => _items(await _tasks.restartTasks(body: TaskSelector(ids: ids))),
  );

  @override
  Future<List<ItemResult>> refreshMany(List<String> ids) => guard(
    () async => _items(await _tasks.refreshTasks(body: TaskSelector(ids: ids))),
  );

  @override
  Future<List<ItemResult>> moveMany(List<String> ids, String queueId) => guard(
    () async => _items(
      await _tasks.moveTasks(
        body: MoveTasksBody(ids: ids, queueId: queueId),
      ),
    ),
  );

  @override
  Future<List<ItemResult>> prioritise(
    List<String> ids,
    UpdateTasksBodyPriority priority,
  ) => guard(
    () async => _items(
      await _tasks.updateTasks(
        body: UpdateTasksBody(ids: ids, priority: priority),
      ),
    ),
  );

  @override
  Future<Task> move(String id, String queueId) => guard(
    () => _tasks.moveTask(
      id: id,
      body: MoveTaskBody(queueId: queueId),
    ),
  );

  @override
  Future<Task> reorder(String id, int position) => guard(
    () => _tasks.reorderTask(
      id: id,
      body: PositionBody(position: position),
    ),
  );

  @override
  Future<Task> update(
    String id, {
    String? name,
    String? dir,
    UpdateTaskBodyPriority? priority,
  }) => guard(
    () => _tasks.updateTask(
      id: id,
      body: UpdateTaskBody(name: name, dir: dir, priority: priority),
    ),
  );

  static List<ItemResult> _items(BatchOutputBody out) => [
    for (final i in out.results ?? const <BatchItem>[])
      ItemResult(
        id: i.id ?? i.task?.id ?? '',
        ok: i.ok,
        task: i.task,
        error: i.error == null
            ? null
            : ApiProblem(
                status: i.error!.status ?? 0,
                code: i.error!.code,
                title: i.error!.title ?? '',
                detail: i.error!.detail ?? '',
                params: i.error!.params ?? const {},
              ),
      ),
  ];
}
