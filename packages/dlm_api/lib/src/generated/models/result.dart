// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'result.g.dart';

@JsonSerializable()
class Result {
  const Result({
    required this.browser,
    required this.status,
    this.manifest,
    this.reason,
    this.registry,
  });

  factory Result.fromJson(Map<String, Object?> json) => _$ResultFromJson(json);

  final String browser;
  final String? manifest;
  final String? reason;
  final String? registry;
  final String status;

  Map<String, Object?> toJson() => _$ResultToJson(this);
}
