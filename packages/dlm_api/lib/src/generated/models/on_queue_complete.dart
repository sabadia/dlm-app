// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'on_queue_complete.g.dart';

@JsonSerializable()
class OnQueueComplete {
  const OnQueueComplete({
    required this.action,
    this.args,
    this.command,
    this.delay,
  });

  factory OnQueueComplete.fromJson(Map<String, Object?> json) =>
      _$OnQueueCompleteFromJson(json);

  final String action;
  final List<String>? args;
  final String? command;
  final String? delay;

  Map<String, Object?> toJson() => _$OnQueueCompleteToJson(this);
}
