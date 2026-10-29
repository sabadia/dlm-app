// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/batch_output_body.dart';
import '../models/bucket.dart';
import '../models/cleanup_result.dart';
import '../models/cleanup_tasks_body.dart';
import '../models/create_task_body.dart';
import '../models/create_tasks_body.dart';
import '../models/delete_tasks_body.dart';
import '../models/effective.dart';
import '../models/expand_tasks_body.dart';
import '../models/expanded_pattern.dart';
import '../models/exported_tasks.dart';
import '../models/format2.dart';
import '../models/group_by.dart';
import '../models/import_tasks_body.dart';
import '../models/move_task_body.dart';
import '../models/move_tasks_body.dart';
import '../models/order.dart';
import '../models/position_body.dart';
import '../models/priority.dart';
import '../models/resolve_result.dart';
import '../models/resolve_task_body.dart';
import '../models/resolve_tasks_body.dart';
import '../models/resolve_tasks_output_body.dart';
import '../models/segment_list.dart';
import '../models/set_task_files_body.dart';
import '../models/sort.dart';
import '../models/stats_body.dart';
import '../models/status.dart';
import '../models/task.dart';
import '../models/task_list.dart';
import '../models/task_selector.dart';
import '../models/timeline.dart';
import '../models/torrent_info.dart';
import '../models/update_task_body.dart';
import '../models/update_tasks_body.dart';

part 'tasks_client.g.dart';

@RestApi()
abstract class TasksClient {
  factory TasksClient(Dio dio, {String? baseUrl}) = _TasksClient;

  /// Resolve a download.
  ///
  /// Probes a URL or source with the effective settings and returns what would be downloaded (name, size, range support). The result is cached under resolveId, which create-task accepts until expiresAt. A failed probe returns 502 with the engine error code.
  @POST('/v1/resolve')
  Future<ResolveResult> resolveTask({@Body() required ResolveTaskBody body});

  /// Resolve several downloads.
  ///
  /// Probes up to 100 sources, a few at a time, and answers one result per item (200 even when some failed). Each success has a resolveId like resolve-task, and duplicateOf when another task already has the link or the file name and size.
  @POST('/v1/resolve/batch')
  Future<ResolveTasksOutputBody> resolveTasks({
    @Body() required ResolveTasksBody body,
  });

  /// Download statistics.
  ///
  /// Task counts per status and engine, bytes downloaded, and what completed in the last day, week and month.
  @GET('/v1/stats')
  Future<StatsBody> getStats();

  /// Traffic over time.
  ///
  /// Bytes downloaded and uploaded per hour or day (UTC), optionally split by engine or queue, for charts. Recorded from when the daemon first measured it; at most 1000 buckets per request (422 otherwise).
  ///
  /// [bucket] - Size of a bucket (UTC).
  ///
  /// [groupBy] - Split every bucket by engine or by queue.
  ///
  /// [from] - Start of the range, inclusive (RFC 3339). Default: 24 hours (bucket=hour) or 30 days (bucket=day) before the end.
  ///
  /// [to] - End of the range, exclusive (RFC 3339). Default: the end of the current bucket.
  @GET('/v1/stats/timeline')
  Future<Timeline> getStatsTimeline({
    @Query('from') DateTime? from,
    @Query('to') DateTime? to,
    @Query('bucket') Bucket? bucket = Bucket.hour,
    @Query('groupBy') GroupBy? groupBy = GroupBy.none,
  });

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
  /// [engine] - Only tasks of this engine (http, bt, ...).
  ///
  /// [label] - Only tasks with this label: key, or key=value.
  ///
  /// [category] - Only tasks that belong to this category (ID or name): their name or content type matches its rules.
  ///
  /// [minSize] - Only tasks of at least this many bytes (-1: no bound; tasks of unknown size are left out).
  ///
  /// [maxSize] - Only tasks of at most this many bytes (-1: no bound; tasks of unknown size are left out).
  ///
  /// [createdAfter] - Only tasks created at or after this time (RFC 3339).
  ///
  /// [createdBefore] - Only tasks created at or before this time (RFC 3339).
  ///
  /// [completedAfter] - Only tasks completed at or after this time (RFC 3339); tasks that are not completed are left out.
  ///
  /// [completedBefore] - Only tasks completed at or before this time (RFC 3339); tasks that are not completed are left out.
  ///
  /// [sort] - position: queue order (priority, then position); created: by creation time (newest first); name: case-insensitive (A to Z); size: smallest first (unknown sizes first); completed: oldest first (tasks that are not completed first).
  ///
  /// [order] - Direction; the default is the one named in sort. The position order has one direction.
  ///
  /// [total] - Also count every task matching the filters (total).
  ///
  /// [limit] - Page size.
  ///
  /// [cursor] - nextCursor of the previous page (same sort and order).
  @GET('/v1/tasks')
  Future<TaskList> listTasks({
    @Query('minSize') int? minSize = -1,
    @Query('maxSize') int? maxSize = -1,
    @Query('sort') Sort? sort = Sort.position,
    @Query('limit') int? limit = 50,
    @Query('queueId') String? queueId,
    @Query('status') List<Status>? status,
    @Query('q') String? q,
    @Query('engine') String? engine,
    @Query('label') String? label,
    @Query('category') String? category,
    @Query('createdAfter') DateTime? createdAfter,
    @Query('createdBefore') DateTime? createdBefore,
    @Query('completedAfter') DateTime? completedAfter,
    @Query('completedBefore') DateTime? completedBefore,
    @Query('order') Order? order,
    @Query('total') bool? total,
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

  /// Remove old completed downloads.
  ///
  /// Removes the completed tasks that finished at least olderThanDays days ago, optionally with their files, and answers how many matched and were removed. A dry run only counts. The retentionDays setting does the same automatically (never touching files).
  @POST('/v1/tasks/cleanup')
  Future<CleanupResult> cleanupTasks({@Body() required CleanupTasksBody body});

  /// Delete tasks.
  ///
  /// Deletes each selected task independently (running tasks are stopped first), optionally with their files.
  @POST('/v1/tasks/delete')
  Future<BatchOutputBody> deleteTasks({@Body() required DeleteTasksBody body});

  /// Preview a URL pattern.
  ///
  /// Says how many URLs a pattern with ranges stands for and lists the first ones, so a client can show a preview before adding them. A pattern that expands to more than 10000 URLs, or a malformed range, is 422.
  @POST('/v1/tasks/expand')
  Future<ExpandedPattern> expandTasks({@Body() required ExpandTasksBody body});

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

  /// Move tasks to another queue.
  ///
  /// Appends each selected task at the end of the target queue. The answer lists the outcome of every task.
  @POST('/v1/tasks/move')
  Future<BatchOutputBody> moveTasks({@Body() required MoveTasksBody body});

  /// Pause tasks.
  ///
  /// Pauses each selected task independently. Returns one result per task.
  @POST('/v1/tasks/pause')
  Future<BatchOutputBody> pauseTasks({@Body() required TaskSelector body});

  /// Refresh the links of tasks.
  ///
  /// Runs the refresh strategies of each selected task now (see refresh-task).
  @POST('/v1/tasks/refresh')
  Future<BatchOutputBody> refreshTasks({@Body() required TaskSelector body});

  /// Restart tasks.
  ///
  /// Downloads each selected finished or failed task again from scratch.
  @POST('/v1/tasks/restart')
  Future<BatchOutputBody> restartTasks({@Body() required TaskSelector body});

  /// Resume tasks.
  ///
  /// Queues each selected paused or failed task again. Returns one result per task.
  @POST('/v1/tasks/resume')
  Future<BatchOutputBody> resumeTasks({@Body() required TaskSelector body});

  /// Add a download from a .torrent file.
  ///
  /// Creates a torrent task from the content of a .torrent file, sent as the request body (Content-Type application/x-bittorrent), up to 16 MiB. Use it instead of a data: URL in create-task, which is limited to the 1 MiB of an ordinary request.
  ///
  /// [queueId] - Queue to add the task to (default: the Main queue).
  ///
  /// [name] - File or folder name without directories (default: the torrent's name).
  ///
  /// [dir] - Absolute download directory (default: the effective downloadDir).
  ///
  /// [priority] - Priority within the queue (default normal).
  ///
  /// [paused] - Create the task paused instead of queued.
  ///
  /// [allowDuplicate] - Add the task even when the same torrent is already a task.
  @POST('/v1/tasks/torrent')
  Future<Task> addTorrentFile({
    @Body() required File body,
    @Query('queueId') String? queueId,
    @Query('name') String? name,
    @Query('dir') String? dir,
    @Query('priority') Priority? priority,
    @Query('paused') bool? paused,
    @Query('allowDuplicate') bool? allowDuplicate,
  });

  /// Change several tasks at once.
  ///
  /// Sets the priority, adds or removes labels, patches the settings overrides and/or moves each selected task. A task that cannot take the change (for example a settings patch it rejects) reports its own error.
  @POST('/v1/tasks/update')
  Future<BatchOutputBody> updateTasks({@Body() required UpdateTasksBody body});

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

  /// Choose the files of a task.
  ///
  /// Changes which files of a multi-file task (a torrent) are downloaded, also after it was created. The task's size follows the selection and the next run downloads exactly the selected files; files already downloaded and no longer selected stay on disk. Active and completed tasks cannot change (409 task.files_locked: pause the task first, restart a completed one); an unknown index or an empty selection is 422.
  ///
  /// [id] - Task ID.
  @PATCH('/v1/tasks/{id}/files')
  Future<Task> updateTaskFiles({
    @Path('id') required String id,
    @Body() required SetTaskFilesBody body,
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

  /// List a task's segments.
  ///
  /// The byte ranges a task downloads in parallel and how much of each is done: the data of a segments map.
  ///
  /// [id] - Task ID.
  @GET('/v1/tasks/{id}/segments')
  Future<SegmentList> listTaskSegments({@Path('id') required String id});

  /// Get a task's effective settings.
  ///
  /// Resolves Defaults ⊕ Global ⊕ Queue ⊕ Task and reports the level each value comes from.
  ///
  /// [id] - Task ID.
  @GET('/v1/tasks/{id}/settings/effective')
  Future<Effective> getTaskEffectiveSettings({@Path('id') required String id});

  /// Describe a torrent task.
  ///
  /// The swarm of a torrent task: state, info hash, trackers, connected peers, bytes shared and the share ratio. Live while the task runs; otherwise what its last run saved (state stopped). 404 task.no_torrent for a task of another engine or a torrent that never ran.
  ///
  /// [id] - Task ID.
  @GET('/v1/tasks/{id}/torrent')
  Future<TorrentInfo> getTaskTorrent({@Path('id') required String id});
}
