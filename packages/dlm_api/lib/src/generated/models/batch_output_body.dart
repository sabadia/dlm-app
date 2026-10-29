// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'batch_item.dart';

part 'batch_output_body.g.dart';

@JsonSerializable()
class BatchOutputBody {
  const BatchOutputBody({required this.results, this.schema});

  factory BatchOutputBody.fromJson(Map<String, Object?> json) =>
      _$BatchOutputBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// One result per item, in request order.
  final List<BatchItem>? results;

  Map<String, Object?> toJson() => _$BatchOutputBodyToJson(this);
}
