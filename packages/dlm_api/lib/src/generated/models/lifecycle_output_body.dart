// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lifecycle_output_body_status.dart';

part 'lifecycle_output_body.g.dart';

@JsonSerializable()
class LifecycleOutputBody {
  const LifecycleOutputBody({required this.status, this.schema});

  factory LifecycleOutputBody.fromJson(Map<String, Object?> json) =>
      _$LifecycleOutputBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// What the daemon is about to do.
  final LifecycleOutputBodyStatus status;

  Map<String, Object?> toJson() => _$LifecycleOutputBodyToJson(this);
}
