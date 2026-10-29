// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_resolved_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingResolvedData _$PairingResolvedDataFromJson(Map<String, dynamic> json) =>
    PairingResolvedData(
      id: json['id'] as String,
      status: PairingResolvedDataStatus.fromJson(json['status'] as String),
      tokenId: json['tokenId'] as String?,
    );

Map<String, dynamic> _$PairingResolvedDataToJson(
  PairingResolvedData instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': _$PairingResolvedDataStatusEnumMap[instance.status]!,
  'tokenId': instance.tokenId,
};

const _$PairingResolvedDataStatusEnumMap = {
  PairingResolvedDataStatus.approved: 'approved',
  PairingResolvedDataStatus.denied: 'denied',
  PairingResolvedDataStatus.expired: 'expired',
  PairingResolvedDataStatus.$unknown: r'$unknown',
};
