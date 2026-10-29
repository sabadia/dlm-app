// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'resolve_item.dart';

part 'resolve_tasks_output_body.g.dart';

@JsonSerializable()
class ResolveTasksOutputBody {
  const ResolveTasksOutputBody({required this.results, this.schema});

  factory ResolveTasksOutputBody.fromJson(Map<String, Object?> json) =>
      _$ResolveTasksOutputBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// One result per item, in the order of the request.
  final List<ResolveItem>? results;

  Map<String, Object?> toJson() => _$ResolveTasksOutputBodyToJson(this);
}
