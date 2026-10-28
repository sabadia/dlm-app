// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'plugin.dart';

part 'plugin_list.g.dart';

@JsonSerializable()
class PluginList {
  const PluginList({required this.plugins, this.schema});

  factory PluginList.fromJson(Map<String, Object?> json) =>
      _$PluginListFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Installed plugins, ordered by name.
  final List<Plugin>? plugins;

  Map<String, Object?> toJson() => _$PluginListToJson(this);
}
