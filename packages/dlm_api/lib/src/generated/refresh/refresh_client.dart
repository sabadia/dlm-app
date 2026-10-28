// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/refresh_history.dart';
import '../models/task.dart';
import '../models/update_task_source_body.dart';

part 'refresh_client.g.dart';

@RestApi()
abstract class RefreshClient {
  factory RefreshClient(Dio dio, {String? baseUrl}) = _RefreshClient;

  /// Refresh a task's link.
  ///
  /// Runs the task's refresh strategies (refresh.strategies) now to obtain a new link for an expired one. A refreshed task is queued again and resumes from where it stopped; when only waiting strategies remain it waits in awaiting_link. Answers 502 when no strategy produced a usable link. Running tasks must be paused first (409).
  ///
  /// [id] - Task ID.
  @POST('/v1/tasks/{id}/refresh')
  Future<Task> refreshTask({@Path('id') required String id});

  /// Wait for a new link from the browser.
  ///
  /// Puts a failed or awaiting_link task into the awaiting_link state: the next download the browser extension captures that matches the task's fingerprint (POST /v1/capture) becomes its new link. The wait ends after refresh.awaitTimeout.
  ///
  /// [id] - Task ID.
  @POST('/v1/tasks/{id}/refresh/await')
  Future<Task> awaitTaskLink({@Path('id') required String id});

  /// List a task's refresh history.
  ///
  /// Every refresh step of the task: strategies that ran or were skipped, waits and their outcome, with the links before and after.
  ///
  /// [id] - Task ID.
  @GET('/v1/tasks/{id}/refresh/history')
  Future<RefreshHistory> listTaskRefreshes({@Path('id') required String id});

  /// Set a task's link.
  ///
  /// Replaces the task's link by hand. The new link is probed and checked against the task's fingerprint (size, strong ETag, file name): on a match the download resumes from its segments, on a mismatch onMismatch decides (409 when the link is rejected). Accepts application/json and application/merge-patch+json. Running tasks must be paused first (409).
  ///
  /// [id] - Task ID.
  @PATCH('/v1/tasks/{id}/source')
  Future<Task> updateTaskSource({
    @Path('id') required String id,
    @Body() required UpdateTaskSourceBody body,
  });
}
