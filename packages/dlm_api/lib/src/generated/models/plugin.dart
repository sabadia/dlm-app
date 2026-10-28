// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'plugin.g.dart';

@JsonSerializable()
class Plugin {
  const Plugin({
    required this.enabled,
    required this.hooks,
    required this.installedAt,
    required this.name,
    required this.source,
    required this.updatedAt,
    required this.version,
    this.schema,
    this.description,
    this.error,
    this.net,
    this.title,
  });

  factory Plugin.fromJson(Map<String, Object?> json) => _$PluginFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final String? description;
  final bool enabled;
  final String? error;
  final List<String>? hooks;
  final DateTime installedAt;
  final String name;
  final List<String>? net;
  final String source;
  final String? title;
  final DateTime updatedAt;
  final String version;

  Map<String, Object?> toJson() => _$PluginToJson(this);
}
