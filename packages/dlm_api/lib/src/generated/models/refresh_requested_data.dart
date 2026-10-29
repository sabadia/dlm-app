// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'fingerprint.dart';

part 'refresh_requested_data.g.dart';

@JsonSerializable()
class RefreshRequestedData {
  const RefreshRequestedData({
    required this.fingerprint,
    required this.name,
    required this.pageUrl,
    this.deadline,
    this.originalUrl,
  });

  factory RefreshRequestedData.fromJson(Map<String, Object?> json) =>
      _$RefreshRequestedDataFromJson(json);

  final DateTime? deadline;
  final Fingerprint fingerprint;
  final String name;
  final String? originalUrl;
  final String pageUrl;

  Map<String, Object?> toJson() => _$RefreshRequestedDataToJson(this);
}
