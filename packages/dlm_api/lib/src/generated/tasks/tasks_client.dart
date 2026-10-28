// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/batch_output_body.dart';
import '../models/create_task_body.dart';
import '../models/create_tasks_body.dart';
import '../models/delete_tasks_body.dart';
import '../models/effective.dart';
import '../models/exported_tasks.dart';
import '../models/format2.dart';
import '../models/import_tasks_body.dart';
import '../models/move_task_body.dart';
import '../models/position_body.dart';
import '../models/resolve_result.dart';
import '../models/resolve_task_body.dart';
import '../models/sort.dart';
import '../models/stats_body.dart';
import '../models/status.dart';
import '../models/task.dart';
import '../models/task_list.dart';
import '../models/task_selector.dart';
import '../models/update_task_body.dart';

part 'tasks_client.g.dart';

@RestApi()
abstract class TasksClient {
  factory TasksClient(Dio dio, {String? baseUrl}) = _TasksClient;

  /// Resolve a download.
  ///
  /// Probes a URL or source with the effective settings and returns what would be downloaded (name, size, range support). The result is cached under resolveId, which create-task accepts until expiresAt. A failed probe returns 502 with the engine error code.
  @POST('/v1/resolve')
  Future<ResolveResult> resolveTask({@Body() required ResolveTaskBody body});

  /// Download statistics.
  ///
  /// Task counts per status and engine, bytes downloaded, and what completed in the last day, week and month.
  @GET('/v1/stats')
  Future<StatsBody> getStats();

  /// List tasks.
  ///
  /// Returns one page of tasks matching the filters. Follow nextCursor (with the same sort) for the next page.
  ///
  /// [queueId] - Only tasks of this queue.
  ///
  /// [status] - Only tasks in any of these states (comma-separated).
  ///
  /// [q] - Case-insensitive substring of the task name or URL.
  ///
  /// [sort] - position: queue order (priority, then position); created: newest first.
  ///
  /// [limit] - Page size.
  ///
  /// [cursor] - nextCursor of the previous page.
  @GET('/v1/tasks')
  Future<TaskList> listTasks({
    @Query('sort') Sort? sort = Sort.position,
    @Query('limit') int? limit = 50,
    @Query('queueId') String? queueId,
    @Query('status') List<Status>? status,
    @Query('q') String? q,
    @Query('cursor') String? cursor,
  });

  /// Create a task.
  ///
  /// Adds a task at the end of its queue, queued (or paused). Pass resolveId to reuse a resolve-task probe.
  @POST('/v1/tasks')
  Future<Task> createTask({@Body() required CreateTaskBody body});

  /// Create several tasks.
  ///
  /// Creates each item independently; one failure does not stop the others. Returns one result per item.
  @POST('/v1/tasks/batch')
  Future<BatchOutputBody> createTasks({@Body() required CreateTasksBody body});

  /// Delete tasks.
  ///
  /// Deletes each selected task independently (running tasks are stopped first), optionally with their files.
  @POST('/v1/tasks/delete')
  Future<BatchOutputBody> deleteTasks({@Body() required DeleteTasksBody body});

  /// Export tasks as a list.
  ///
  /// Writes the matching tasks as dlm JSON, a plain list of URLs, or an aria2 input file. Captured headers and cookies are never exported.
  ///
  /// [format] - json (dlm's own), urls (one link per line) or aria2 (aria2's input file).
  ///
  /// [queueId] - Only tasks of this queue.
  ///
  /// [status] - Only tasks in any of these states (comma-separated).
  ///
  /// [q] - Case-insensitive substring of the task name or URL.
  @GET('/v1/tasks/export')
  Future<ExportedTasks> exportTasks({
    @Query('queueId') String? queueId,
    @Query('status') List<Status>? status,
    @Query('q') String? q,
    @Query('format') Format2? format = Format2.valueJson,
  });

  /// Import a list of downloads.
  ///
  /// Creates one task per entry of a dlm JSON, URL list, or aria2 input file, independently: one failure does not stop the others. Returns one result per created task. An unreadable list is refused with 422 and creates nothing.
  @POST('/v1/tasks/import')
  Future<BatchOutputBody> importTasks({@Body() required ImportTasksBody body});

  /// Pause tasks.
  ///
  /// Pauses each selected task independently. Returns one result per task.
  @POST('/v1/tasks/pause')
  Future<BatchOutputBody> pauseTasks({@Body() required TaskSelector body});

  /// Resume tasks.
  ///
  /// Queues each selected paused or failed task again. Returns one result per task.
  @POST('/v1/tasks/resume')
  Future<BatchOutputBody> resumeTasks({@Body() required TaskSelector body});

  /// Delete a task.
  ///
  /// Deletes the task (stopping it first if running), optionally with its files.
  ///
  /// [id] - Task ID.
  ///
  /// [files] - Also delete the partial and downloaded files.
  @DELETE('/v1/tasks/{id}')
  Future<void> deleteTask({
    @Path('id') required String id,
    @Query('files') bool? files,
  });

  /// Get a task.
  ///
  /// [id] - Task ID.
  @GET('/v1/tasks/{id}')
  Future<Task> getTask({@Path('id') required String id});

  /// Update a task.
  ///
  /// Changes name, dir, priority, labels (replaced as a whole; {} removes them) and/or settings overrides. settings is an RFC 7396 merge patch: null unsets a field. Name and dir cannot change while the task is active or has partial data (409).
  ///
  /// [id] - Task ID.
  @PATCH('/v1/tasks/{id}')
  Future<Task> updateTask({
    @Path('id') required String id,
    @Body() required UpdateTaskBody body,
  });

  /// Move a task to another queue.
  ///
  /// Appends the task at the end of the target queue.
  ///
  /// [id] - Task ID.
  @POST('/v1/tasks/{id}/move')
  Future<Task> moveTask({
    @Path('id') required String id,
    @Body() required MoveTaskBody body,
  });

  /// Reorder a task within its queue.
  ///
  /// [id] - Task ID.
  @POST('/v1/tasks/{id}/reorder')
  Future<Task> reorderTask({
    @Path('id') required String id,
    @Body() required PositionBody body,
  });

  /// Restart a task.
  ///
  /// Downloads a completed or failed task again from scratch. Fails with 409 while the downloaded file exists.
  ///
  /// [id] - Task ID.
  @POST('/v1/tasks/{id}/restart')
  Future<Task> restartTask({@Path('id') required String id});

  /// Get a task's effective settings.
  ///
  /// Resolves Defaults ⊕ Global ⊕ Queue ⊕ Task and reports the level each value comes from.
  ///
  /// [id] - Task ID.
  @GET('/v1/tasks/{id}/settings/effective')
  Future<Effective> getTaskEffectiveSettings({@Path('id') required String id});
}
