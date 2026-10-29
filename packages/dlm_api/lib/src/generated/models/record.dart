// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'record_level.dart';

part 'record.g.dart';

@JsonSerializable()
class Record {
  const Record({
    required this.id,
    required this.level,
    required this.message,
    required this.time,
    this.attrs,
  });

  factory Record.fromJson(Map<String, Object?> json) => _$RecordFromJson(json);

  final Map<String, dynamic>? attrs;
  final int id;
  final RecordLevel level;
  final String message;
  final DateTime time;

  Map<String, Object?> toJson() => _$RecordToJson(this);
}
