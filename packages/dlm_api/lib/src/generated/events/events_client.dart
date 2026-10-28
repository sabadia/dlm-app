// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/stream_event.dart';

part 'events_client.g.dart';

@RestApi()
abstract class EventsClient {
  factory EventsClient(Dio dio, {String? baseUrl}) = _EventsClient;

  /// Stream events (SSE).
  ///
  /// Streams events as Server-Sent Events (text/event-stream).
  ///
  /// Each event is sent as:.
  ///
  ///     id: <bootID>-<seq>.
  ///     event: <type>            (e.g. task.progress, task.status).
  ///     data: <JSON event>.
  ///
  /// The id combines a token identifying the daemon process with the bus sequence.
  /// number, so a reconnecting client's Last-Event-ID is only honoured by the same.
  /// daemon process. On reconnect with Last-Event-ID the missed events are replayed.
  /// before live events. A `reset` event (data `{"reason": "restart"|"gap"|"overflow"}`).
  /// tells the client it missed events and must refetch the state it mirrors:.
  /// "restart" when the Last-Event-ID belongs to another daemon process, "gap" when.
  /// the replay is incomplete, "overflow" when the client read too slowly.
  /// A ": ping" comment is sent periodically to keep proxies from closing the.
  /// connection.
  @GET('/v1/events')
  Future<StreamEvent> streamEvents();
}
