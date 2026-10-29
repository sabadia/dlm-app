// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scope_limits.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScopeLimits _$ScopeLimitsFromJson(Map<String, dynamic> json) => ScopeLimits(
  configuredSpeedLimit: (json['configuredSpeedLimit'] as num).toInt(),
  speedLimit: (json['speedLimit'] as num).toInt(),
  activeProfile: json['activeProfile'] == null
      ? null
      : ProfileView.fromJson(json['activeProfile'] as Map<String, dynamic>),
  name: json['name'] as String?,
  queueId: json['queueId'] as String?,
  quota: json['quota'] == null
      ? null
      : QuotaView.fromJson(json['quota'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ScopeLimitsToJson(ScopeLimits instance) =>
    <String, dynamic>{
      'activeProfile': instance.activeProfile,
      'configuredSpeedLimit': instance.configuredSpeedLimit,
      'name': instance.name,
      'queueId': instance.queueId,
      'quota': instance.quota,
      'speedLimit': instance.speedLimit,
    };
