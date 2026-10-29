// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'native_host_request_action.dart';

part 'native_host_request.g.dart';

@JsonSerializable()
class NativeHostRequest {
  const NativeHostRequest({
    required this.action,
    this.schema,
    this.browsers,
    this.extensionIds,
    this.firefoxIds,
  });

  factory NativeHostRequest.fromJson(Map<String, Object?> json) =>
      _$NativeHostRequestFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// install registers the host with the browsers, uninstall removes it.
  final NativeHostRequestAction action;

  /// Limit to these browsers (see get-native-host for the names); default: all.
  final List<String>? browsers;

  /// More Chromium extension IDs or chrome-extension://ID/ origins to allow (install), besides the published extension; default: the chrome-extension:// entries of server.allowed_origins.
  final List<String>? extensionIds;

  /// More Firefox add-on IDs to allow (install), besides the published extension.
  final List<String>? firefoxIds;

  Map<String, Object?> toJson() => _$NativeHostRequestToJson(this);
}
