// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'settings.dart';
import 'source_input.dart';

part 'resolve_task_body.g.dart';

@JsonSerializable()
class ResolveTaskBody {
  const ResolveTaskBody({
    this.schema,
    this.queueId,
    this.settings,
    this.source,
    this.url,
  });

  factory ResolveTaskBody.fromJson(Map<String, Object?> json) =>
      _$ResolveTaskBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Queue whose settings apply (default: the Main queue).
  final String? queueId;

  /// Task-level settings overrides used for the probe.
  final Settings? settings;

  /// Full source description. Mutually exclusive with url.
  final SourceInput? source;

  /// URL to download; shorthand for source.currentUrl. Mutually exclusive with source.
  final String? url;

  Map<String, Object?> toJson() => _$ResolveTaskBodyToJson(this);
}
