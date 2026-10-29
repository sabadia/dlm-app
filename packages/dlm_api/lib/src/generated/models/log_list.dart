// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'record.dart';

part 'log_list.g.dart';

@JsonSerializable()
class LogList {
  const LogList({
    required this.bootId,
    required this.hasMore,
    required this.lastId,
    required this.records,
    this.schema,
  });

  factory LogList.fromJson(Map<String, Object?> json) =>
      _$LogListFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Identifies this daemon process; record ids restart with it. Stream ids are <bootId>-<id>.
  final String bootId;

  /// Older matching records exist: ask again with before set to the first id.
  final bool hasMore;

  /// Id of the newest record the daemon has (0 when it has none), also when it does not match: start a stream after it.
  final int lastId;

  /// The newest matching records, oldest first.
  final List<Record>? records;

  Map<String, Object?> toJson() => _$LogListToJson(this);
}
