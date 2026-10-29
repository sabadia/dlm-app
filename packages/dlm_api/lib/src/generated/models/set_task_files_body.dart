// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'set_task_files_body.g.dart';

@JsonSerializable()
class SetTaskFilesBody {
  const SetTaskFilesBody({required this.selected, this.schema});

  factory SetTaskFilesBody.fromJson(Map<String, Object?> json) =>
      _$SetTaskFilesBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// The indexes of the files to download; every other file of the task is skipped. At least one file must stay selected.
  final List<int>? selected;

  Map<String, Object?> toJson() => _$SetTaskFilesBodyToJson(this);
}
