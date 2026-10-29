// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_v1_logs_stream_response_sealed.dart';
import '../models/level.dart';
import '../models/log_list.dart';

part 'logs_client.g.dart';

@RestApi()
abstract class LogsClient {
  factory LogsClient(Dio dio, {String? baseUrl}) = _LogsClient;

  /// Read the daemon's log.
  ///
  /// The daemon keeps its most recent log records (the last 5000 since it started) in memory. This lists them, newest last, filtered by level, text and time; older records are in the log file of the daemon's log directory.
  ///
  /// [level] - Only records of at least this level (default: all that were kept).
  ///
  /// [q] - Only records whose message or attributes contain this text, ignoring case.
  ///
  /// [since] - Only records at or after this time (RFC 3339).
  ///
  /// [until] - Only records at or before this time (RFC 3339).
  ///
  /// [before] - Only records older than this id: pass the first id of the previous answer to page backwards.
  ///
  /// [limit] - How many records, counted from the newest.
  @GET('/v1/logs')
  Future<LogList> getLogs({
    @Query('limit') int? limit = 200,
    @Query('level') Level? level,
    @Query('q') String? q,
    @Query('since') DateTime? since,
    @Query('until') DateTime? until,
    @Query('before') int? before,
  });

  /// Stream the daemon's log (SSE).
  ///
  /// Streams log records as Server-Sent Events: event name log, data a LogRecord, id <bootId>-<id>. With Last-Event-ID (or lastEventId) the records after it that are still kept are sent first; when some were already dropped a reset event with reason gap comes first, and one with reason overflow when the client reads too slowly. get-logs answers the id to start from (lastId).
  ///
  /// [level] - Only records of at least this level.
  ///
  /// [q] - Only records whose message or attributes contain this text, ignoring case.
  ///
  /// [lastEventId] - Fallback for clients that cannot set the Last-Event-ID header; the header takes precedence.
  @GET('/v1/logs/stream')
  Future<List<GetV1LogsStreamResponseSealed>> streamLogs({
    @Query('level') Level? level,
    @Query('q') String? q,
    @Query('lastEventId') String? lastEventId,
  });
}
