// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'running.g.dart';

@JsonSerializable()
class Running {
  const Running({required this.group, required this.sessions});

  factory Running.fromJson(Map<String, Object?> json) =>
      _$RunningFromJson(json);

  final String group;
  final int sessions;

  Map<String, Object?> toJson() => _$RunningToJson(this);
}
