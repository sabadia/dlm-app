// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pairing_resolved_data_status.dart';

part 'pairing_resolved_data.g.dart';

@JsonSerializable()
class PairingResolvedData {
  const PairingResolvedData({
    required this.id,
    required this.status,
    this.tokenId,
  });

  factory PairingResolvedData.fromJson(Map<String, Object?> json) =>
      _$PairingResolvedDataFromJson(json);

  final String id;
  final PairingResolvedDataStatus status;
  final String? tokenId;

  Map<String, Object?> toJson() => _$PairingResolvedDataToJson(this);
}
