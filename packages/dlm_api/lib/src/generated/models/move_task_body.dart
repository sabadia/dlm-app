// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'move_task_body.g.dart';

@JsonSerializable()
class MoveTaskBody {
  const MoveTaskBody({required this.queueId, this.schema});

  factory MoveTaskBody.fromJson(Map<String, Object?> json) =>
      _$MoveTaskBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Target queue ID.
  final String queueId;

  Map<String, Object?> toJson() => _$MoveTaskBodyToJson(this);
}
