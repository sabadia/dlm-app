// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/update_config_body.dart';
import '../models/view.dart';

part 'config_client.g.dart';

@RestApi()
abstract class ConfigClient {
  factory ConfigClient(Dio dio, {String? baseUrl}) = _ConfigClient;

  /// Boot configuration.
  ///
  /// Every boot configuration key with the value the running daemon uses, its default, where the value came from (default, file, env or flag) and whether the config file now holds a different value that applies at the next start (pending). All of it needs a restart to take effect. Secrets are never shown.
  @GET('/v1/config')
  Future<View> getConfig();

  /// Change the boot configuration.
  ///
  /// Writes keys into the daemon's config file (other keys are kept, comments are not) after checking that the result loads and validates; nothing is written otherwise (422). The running daemon is not changed: restart it (restart-daemon) to apply the change. A key an environment variable or a flag overrides is written as well but keeps its running value. Answers like get-config.
  @PATCH('/v1/config')
  Future<View> updateConfig({@Body() required UpdateConfigBody body});
}
