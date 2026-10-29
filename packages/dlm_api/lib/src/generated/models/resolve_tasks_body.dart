// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'resolve_task_body.dart';

part 'resolve_tasks_body.g.dart';

@JsonSerializable()
class ResolveTasksBody {
  const ResolveTasksBody({required this.items, this.schema});

  factory ResolveTasksBody.fromJson(Map<String, Object?> json) =>
      _$ResolveTasksBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// The downloads to probe; each is like a resolve-task request.
  final List<ResolveTaskBody>? items;

  Map<String, Object?> toJson() => _$ResolveTasksBodyToJson(this);
}
