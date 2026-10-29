// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'duplicate_hint.g.dart';

@JsonSerializable()
class DuplicateHint {
  const DuplicateHint({
    required this.name,
    required this.status,
    required this.taskId,
  });

  factory DuplicateHint.fromJson(Map<String, Object?> json) =>
      _$DuplicateHintFromJson(json);

  final String name;
  final String status;
  final String taskId;

  Map<String, Object?> toJson() => _$DuplicateHintToJson(this);
}
