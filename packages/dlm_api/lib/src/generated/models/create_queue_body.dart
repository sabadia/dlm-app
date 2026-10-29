// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'create_queue_body_state.dart';
import 'settings.dart';

part 'create_queue_body.g.dart';

@JsonSerializable()
class CreateQueueBody {
  const CreateQueueBody({
    required this.name,
    this.schema,
    this.settings,
    this.state,
  });

  factory CreateQueueBody.fromJson(Map<String, Object?> json) =>
      _$CreateQueueBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Unique (case-insensitive) queue name.
  final String name;

  /// Queue-level settings overrides.
  final Settings? settings;

  /// Initial state (default running).
  final CreateQueueBodyState? state;

  Map<String, Object?> toJson() => _$CreateQueueBodyToJson(this);
}
