// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/health_output_body.dart';
import '../models/lifecycle_output_body.dart';
import '../models/system_info.dart';

part 'system_client.g.dart';

@RestApi()
abstract class SystemClient {
  factory SystemClient(Dio dio, {String? baseUrl}) = _SystemClient;

  /// Check daemon health.
  ///
  /// Reports that the daemon is up, its version, and whether the presented bearer token (if any) is valid. Does not require authentication.
  @GET('/v1/health')
  Future<HealthOutputBody> getHealth();

  /// Describe the daemon and its machine.
  ///
  /// Reports the daemon's version, API version, build, operating system, process, listen address, directories, enabled engines, the status of the external tools (ffmpeg, yt-dlp, browser; none is downloaded by this call) and the database size. `local` tells whether this request came from the daemon's own machine, for clients that offer features only meaningful there (folder pickers, opening files).
  @GET('/v1/system/info')
  Future<SystemInfo> getSystemInfo();

  /// Restart the daemon.
  ///
  /// Gracefully stops the daemon and starts it again with the same arguments (the process keeps its pid where the platform allows). Clients reconnect using runtime.json or the same address.
  @POST('/v1/system/restart')
  Future<LifecycleOutputBody> restartDaemon();

  /// Stop the daemon.
  ///
  /// Starts a graceful shutdown: running downloads are stopped and requeued, then the daemon exits. The response is sent before it stops.
  @POST('/v1/system/shutdown')
  Future<LifecycleOutputBody> shutdownDaemon();
}
