// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'pairing_requested_data.g.dart';

@JsonSerializable()
class PairingRequestedData {
  const PairingRequestedData({
    required this.browser,
    required this.code,
    required this.expiresAt,
    required this.id,
    required this.name,
    this.clientId,
    this.clientVersion,
  });

  factory PairingRequestedData.fromJson(Map<String, Object?> json) =>
      _$PairingRequestedDataFromJson(json);

  final String browser;
  final String? clientId;
  final String? clientVersion;
  final String code;
  final DateTime expiresAt;
  final String id;
  final String name;

  Map<String, Object?> toJson() => _$PairingRequestedDataToJson(this);
}
