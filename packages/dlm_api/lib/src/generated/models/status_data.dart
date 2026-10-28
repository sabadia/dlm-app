// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'task_error.dart';

part 'status_data.g.dart';

@JsonSerializable()
class StatusData {
  const StatusData({required this.from, required this.to, this.error});

  factory StatusData.fromJson(Map<String, Object?> json) =>
      _$StatusDataFromJson(json);

  final TaskError? error;
  final String from;
  final String to;

  Map<String, Object?> toJson() => _$StatusDataToJson(this);
}
