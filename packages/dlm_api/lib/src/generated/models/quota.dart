// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'quota.g.dart';

@JsonSerializable()
class Quota {
  const Quota({required this.bytes, required this.period});

  factory Quota.fromJson(Map<String, Object?> json) => _$QuotaFromJson(json);

  final int bytes;
  final String period;

  Map<String, Object?> toJson() => _$QuotaToJson(this);
}
