// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/install_plugin_body.dart';
import '../models/level.dart';
import '../models/log_list.dart';
import '../models/plugin.dart';
import '../models/plugin_list.dart';
import '../models/update_plugin_body.dart';

part 'plugins_client.g.dart';

@RestApi()
abstract class PluginsClient {
  factory PluginsClient(Dio dio, {String? baseUrl}) = _PluginsClient;

  /// List plugins.
  ///
  /// Plugins are JavaScript extensions that resolve links, refresh expired links and react to downloads starting, failing and completing.
  @GET('/v1/plugins')
  Future<PluginList> listPlugins();

  /// Install a plugin.
  ///
  /// Copies a plugin from a directory, or clones it from a git repository, checks its manifest and script, and starts it. A plugin runs inside the daemon and may contact the hosts its manifest lists: install only plugins you trust.
  @POST('/v1/plugins')
  Future<Plugin> installPlugin({@Body() required InstallPluginBody body});

  /// Uninstall a plugin.
  ///
  /// Removes the plugin, its files and the data it stored.
  ///
  /// [name] - Plugin name.
  @DELETE('/v1/plugins/{name}')
  Future<void> deletePlugin({@Path('name') required String name});

  /// Get a plugin.
  ///
  /// [name] - Plugin name.
  @GET('/v1/plugins/{name}')
  Future<Plugin> getPlugin({@Path('name') required String name});

  /// Switch a plugin on or off.
  ///
  /// [name] - Plugin name.
  @PATCH('/v1/plugins/{name}')
  Future<Plugin> updatePlugin({
    @Path('name') required String name,
    @Body() required UpdatePluginBody body,
  });

  /// Read a plugin's log.
  ///
  /// The latest log records of a plugin (500 are kept): what its script wrote with dlm.log and what the daemon said about it (failed starts, failed hooks). Same filters and paging as get-logs.
  ///
  /// [name] - Plugin name.
  ///
  /// [level] - Only records of at least this level.
  ///
  /// [q] - Only records whose message or attributes contain this text, ignoring case.
  ///
  /// [before] - Only records older than this id: pass the first id of the previous answer to page backwards.
  ///
  /// [limit] - How many records, counted from the newest.
  @GET('/v1/plugins/{name}/logs')
  Future<LogList> getPluginLogs({
    @Path('name') required String name,
    @Query('limit') int? limit = 200,
    @Query('level') Level? level,
    @Query('q') String? q,
    @Query('before') int? before,
  });
}
