// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'quota_view.g.dart';

@JsonSerializable()
class QuotaView {
  const QuotaView({
    required this.bytes,
    required this.exhausted,
    required this.period,
    required this.used,
    this.resetsAt,
    this.windowStart,
  });

  factory QuotaView.fromJson(Map<String, Object?> json) =>
      _$QuotaViewFromJson(json);

  final int bytes;
  final bool exhausted;
  final String period;
  final DateTime? resetsAt;
  final int used;
  final DateTime? windowStart;

  Map<String, Object?> toJson() => _$QuotaViewToJson(this);
}
