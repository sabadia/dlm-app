// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_config_body.g.dart';

@JsonSerializable()
class UpdateConfigBody {
  const UpdateConfigBody({required this.values, this.schema});

  factory UpdateConfigBody.fromJson(Map<String, Object?> json) =>
      _$UpdateConfigBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Keys to change, by dotted name (log.level, torrent.dht, server.fs_roots): a value sets the key in the config file, null removes it so the default applies again. Durations are text ("30s"), lists are arrays of strings.
  final Map<String, dynamic> values;

  Map<String, Object?> toJson() => _$UpdateConfigBodyToJson(this);
}
