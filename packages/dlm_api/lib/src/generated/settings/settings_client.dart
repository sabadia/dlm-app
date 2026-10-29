// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/limits_view.dart';
import '../models/override_limits_body.dart';
import '../models/schema.dart';
import '../models/settings.dart';

part 'settings_client.g.dart';

@RestApi()
abstract class SettingsClient {
  factory SettingsClient(Dio dio, {String? baseUrl}) = _SettingsClient;

  /// Speed limits and quotas in force.
  ///
  /// The global speed limit now in force (and the configured one when a temporary override replaces it), the active speed profile, the quota usage of the global scope, and the same per queue.
  @GET('/v1/limits')
  Future<LimitsView> getLimits();

  /// End the temporary speed limit.
  ///
  /// Ends a temporary global speed override now; without one it does nothing. Answers like get-limits.
  @DELETE('/v1/limits/override')
  Future<LimitsView> clearLimitsOverride();

  /// Temporarily replace the global speed limit.
  ///
  /// Replaces the global speed limit by speedLimit (0: unlimited, "turbo") for 1 to 1440 minutes; the configured limit and profiles apply again afterwards. A new override replaces the previous one. Clients are told with a limits.changed event, also when the override ends.
  @POST('/v1/limits/override')
  Future<LimitsView> setLimitsOverride({
    @Body() required OverrideLimitsBody body,
  });

  /// Get the global settings.
  ///
  /// Returns the stored global settings layer; unset fields inherit the defaults (see get-default-settings).
  @GET('/v1/settings')
  Future<Settings> getSettings();

  /// Patch the global settings.
  ///
  /// Applies an RFC 7396 JSON merge patch to the global settings layer (null unsets a field). Accepts application/json and application/merge-patch+json.
  ///
  /// [ifMatch] - ETag of the settings last read; the update fails with 412 (settings.changed) if they changed since.
  ///
  /// [body] - RFC 7396 JSON merge patch of a Settings layer: absent fields are kept, null unsets a field (it inherits from the next lower level again), retry and refresh merge recursively, every other value replaces the field as a whole.
  @PATCH('/v1/settings')
  Future<Settings> patchSettings({
    @Body() required dynamic body,
    @Header('If-Match') String? ifMatch,
  });

  /// Replace the global settings.
  ///
  /// Replaces the global settings layer as a whole.
  ///
  /// [ifMatch] - ETag of the settings last read; the update fails with 412 (settings.changed) if they changed since.
  @PUT('/v1/settings')
  Future<Settings> replaceSettings({
    @Body() required Settings body,
    @Header('If-Match') String? ifMatch,
  });

  /// Get the default settings.
  ///
  /// Returns the built-in lowest settings layer.
  @GET('/v1/settings/defaults')
  Future<Settings> getDefaultSettings();

  /// Describe the settings fields.
  ///
  /// Returns one entry per settings field with its type, group, unit, numeric bounds, accepted values and the levels (default, global, queue, task) that may set it, for building generic settings forms.
  @GET('/v1/settings/schema')
  Future<Schema> getSettingsSchema();
}
