// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_queue_body.dart';
import '../models/effective.dart';
import '../models/position_body.dart';
import '../models/queue.dart';
import '../models/queue_list.dart';
import '../models/settings.dart';
import '../models/update_queue_body.dart';

part 'queues_client.g.dart';

@RestApi()
abstract class QueuesClient {
  factory QueuesClient(Dio dio, {String? baseUrl}) = _QueuesClient;

  /// List queues
  @GET('/v1/queues')
  Future<QueueList> listQueues();

  /// Create a queue.
  ///
  /// Adds a queue at the end of the queue order.
  @POST('/v1/queues')
  Future<Queue> createQueue({@Body() required CreateQueueBody body});

  /// Delete a queue.
  ///
  /// Deletes a queue. A queue that still has tasks needs moveTasksTo; the Main queue cannot be deleted (409).
  ///
  /// [id] - Queue ID.
  ///
  /// [moveTasksTo] - Queue that receives the deleted queue's tasks (appended at its end).
  @DELETE('/v1/queues/{id}')
  Future<void> deleteQueue({
    @Path('id') required String id,
    @Query('moveTasksTo') String? moveTasksTo,
  });

  /// Get a queue.
  ///
  /// [id] - Queue ID.
  @GET('/v1/queues/{id}')
  Future<Queue> getQueue({@Path('id') required String id});

  /// Update a queue.
  ///
  /// Renames a queue and/or patches its settings overrides (RFC 7396 merge patch: null unsets a field).
  ///
  /// [id] - Queue ID.
  @PATCH('/v1/queues/{id}')
  Future<Queue> updateQueue({
    @Path('id') required String id,
    @Body() required UpdateQueueBody body,
  });

  /// Reorder a queue.
  ///
  /// [id] - Queue ID.
  @POST('/v1/queues/{id}/reorder')
  Future<Queue> reorderQueue({
    @Path('id') required String id,
    @Body() required PositionBody body,
  });

  /// Replace a queue's settings.
  ///
  /// Replaces the queue's settings overrides as a whole (unset fields inherit from the global layer).
  ///
  /// [id] - Queue ID.
  @PUT('/v1/queues/{id}/settings')
  Future<Queue> replaceQueueSettings({
    @Path('id') required String id,
    @Body() required Settings body,
  });

  /// Get a queue's effective settings.
  ///
  /// Resolves Defaults ⊕ Global ⊕ Queue and reports the level each value comes from.
  ///
  /// [id] - Queue ID.
  @GET('/v1/queues/{id}/settings/effective')
  Future<Effective> getQueueEffectiveSettings({@Path('id') required String id});

  /// Start a queue.
  ///
  /// Lets the scheduler run the queue's tasks.
  ///
  /// [id] - Queue ID.
  @POST('/v1/queues/{id}/start')
  Future<Queue> startQueue({@Path('id') required String id});

  /// Stop a queue.
  ///
  /// Stops admitting the queue's tasks; running tasks return to queued.
  ///
  /// [id] - Queue ID.
  @POST('/v1/queues/{id}/stop')
  Future<Queue> stopQueue({@Path('id') required String id});
}
