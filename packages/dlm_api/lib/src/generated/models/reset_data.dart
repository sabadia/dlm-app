// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'reset_data_reason.dart';

part 'reset_data.g.dart';

@JsonSerializable()
class ResetData {
  const ResetData({required this.reason});

  factory ResetData.fromJson(Map<String, Object?> json) =>
      _$ResetDataFromJson(json);

  /// Why the client must refetch its state.
  final ResetDataReason reason;

  Map<String, Object?> toJson() => _$ResetDataToJson(this);
}
