// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'entry.dart';

part 'view.g.dart';

@JsonSerializable()
class View {
  const View({
    required this.entries,
    required this.file,
    required this.fileExists,
    required this.restartPending,
    this.schema,
    this.fileError,
  });

  factory View.fromJson(Map<String, Object?> json) => _$ViewFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;
  final List<Entry>? entries;
  final String file;
  final String? fileError;
  final bool fileExists;
  final bool restartPending;

  Map<String, Object?> toJson() => _$ViewToJson(this);
}
