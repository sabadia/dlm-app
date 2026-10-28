// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'action_cancelled_data.g.dart';

@JsonSerializable()
class ActionCancelledData {
  const ActionCancelledData({required this.action, required this.reason});

  factory ActionCancelledData.fromJson(Map<String, Object?> json) =>
      _$ActionCancelledDataFromJson(json);

  final String action;
  final String reason;

  Map<String, Object?> toJson() => _$ActionCancelledDataToJson(this);
}
