// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'time_window.dart';

part 'schedule.g.dart';

@JsonSerializable()
class Schedule {
  const Schedule({required this.windows, this.timezone});

  factory Schedule.fromJson(Map<String, Object?> json) =>
      _$ScheduleFromJson(json);

  final String? timezone;
  final List<TimeWindow>? windows;

  Map<String, Object?> toJson() => _$ScheduleToJson(this);
}
