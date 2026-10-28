// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_queue_body.g.dart';

@JsonSerializable()
class UpdateQueueBody {
  const UpdateQueueBody({this.schema, this.name, this.settings});

  factory UpdateQueueBody.fromJson(Map<String, Object?> json) =>
      _$UpdateQueueBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// New queue name.
  final String? name;

  /// Merge patch of the queue's settings overrides; null values unset fields.
  final dynamic settings;

  Map<String, Object?> toJson() => _$UpdateQueueBodyToJson(this);
}
