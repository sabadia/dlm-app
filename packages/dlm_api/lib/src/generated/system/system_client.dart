// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/fs_free.dart';
import '../models/fs_listing.dart';
import '../models/health_output_body.dart';
import '../models/lifecycle_output_body.dart';
import '../models/system_info.dart';

part 'system_client.g.dart';

@RestApi()
abstract class SystemClient {
  factory SystemClient(Dio dio, {String? baseUrl}) = _SystemClient;

  /// List directories on the daemon's machine.
  ///
  /// Lists the sub-directories of a directory below server.fs_roots, for choosing a download directory on a daemon that runs elsewhere. Without a path it lists the roots. 404 fs.disabled when server.fs_roots is empty; 422 for a path outside the roots (also through symbolic links), not absolute or not a directory.
  ///
  /// [path] - An absolute directory below server.fs_roots; empty lists the roots.
  @GET('/v1/fs/browse')
  Future<FsListing> getFsBrowse({@Query('path') String? path});

  /// Free space of a directory on the daemon's machine.
  ///
  /// The bytes available to the daemon in a directory below server.fs_roots. Same errors as get-fs-browse.
  ///
  /// [path] - An absolute directory below server.fs_roots; empty lists the roots.
  @GET('/v1/fs/free')
  Future<FsFree> getFsFree({@Query('path') String? path});

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
