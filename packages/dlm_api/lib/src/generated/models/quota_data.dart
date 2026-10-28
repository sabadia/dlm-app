// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'quota_data.g.dart';

@JsonSerializable()
class QuotaData {
  const QuotaData({
    required this.bytes,
    required this.period,
    required this.scope,
    required this.used,
    this.queueId,
    this.resetsAt,
    this.windowStart,
  });

  factory QuotaData.fromJson(Map<String, Object?> json) =>
      _$QuotaDataFromJson(json);

  final int bytes;
  final String period;
  final String? queueId;
  final DateTime? resetsAt;
  final String scope;
  final int used;
  final DateTime? windowStart;

  Map<String, Object?> toJson() => _$QuotaDataToJson(this);
}
