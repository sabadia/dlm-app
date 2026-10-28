// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'error_detail.dart';

part 'problem.g.dart';

@JsonSerializable()
class Problem {
  const Problem({
    required this.code,
    this.type = 'about:blank',
    this.schema,
    this.detail,
    this.errors,
    this.instance,
    this.params,
    this.status,
    this.title,
  });

  factory Problem.fromJson(Map<String, Object?> json) =>
      _$ProblemFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Stable machine-readable error code, for example task.not_found, task.duplicate or validation_failed. Clients map it to a localised message; unknown codes fall back to title and detail.
  final String code;

  /// A human-readable explanation specific to this occurrence of the problem.
  final String? detail;

  /// Optional list of individual error details
  final List<ErrorDetail>? errors;

  /// A URI reference that identifies the specific occurrence of the problem.
  final String? instance;

  /// Values for the localised message of the code (ids, names, statuses).
  final Map<String, String>? params;

  /// HTTP status code
  final int? status;

  /// A short, human-readable summary of the problem type. This value should not change between occurrences of the error.
  final String? title;

  /// A URI reference to human-readable documentation for the error.
  final String type;

  Map<String, Object?> toJson() => _$ProblemToJson(this);
}
