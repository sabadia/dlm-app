// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'settings.dart';

part 'queue.g.dart';

@JsonSerializable()
class Queue {
  const Queue({
    required this.createdAt,
    required this.id,
    required this.isDefault,
    required this.name,
    required this.position,
    required this.settings,
    required this.state,
    required this.updatedAt,
    this.schema,
  });

  factory Queue.fromJson(Map<String, Object?> json) => _$QueueFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final DateTime createdAt;
  final String id;
  final bool isDefault;
  final String name;
  final int position;
  final Settings settings;
  final String state;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$QueueToJson(this);
}
