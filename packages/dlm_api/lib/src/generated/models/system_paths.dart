// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'system_paths.g.dart';

@JsonSerializable()
class SystemPaths {
  const SystemPaths({
    required this.cache,
    required this.config,
    required this.data,
    required this.database,
    required this.downloads,
    required this.log,
  });

  factory SystemPaths.fromJson(Map<String, Object?> json) =>
      _$SystemPathsFromJson(json);

  /// Cache directory (downloaded tools).
  final String cache;

  /// Configuration directory (token, runtime.json).
  final String config;

  /// Data directory.
  final String data;

  /// SQLite database file.
  final String database;

  /// Default download directory.
  final String downloads;

  /// Log directory.
  final String log;

  Map<String, Object?> toJson() => _$SystemPathsToJson(this);
}
