// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_requested_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefreshRequestedData _$RefreshRequestedDataFromJson(
  Map<String, dynamic> json,
) => RefreshRequestedData(
  fingerprint: Fingerprint.fromJson(
    json['fingerprint'] as Map<String, dynamic>,
  ),
  name: json['name'] as String,
  pageUrl: json['pageUrl'] as String,
  deadline: json['deadline'] == null
      ? null
      : DateTime.parse(json['deadline'] as String),
  originalUrl: json['originalUrl'] as String?,
);

Map<String, dynamic> _$RefreshRequestedDataToJson(
  RefreshRequestedData instance,
) => <String, dynamic>{
  'deadline': instance.deadline?.toIso8601String(),
  'fingerprint': instance.fingerprint,
  'name': instance.name,
  'originalUrl': instance.originalUrl,
  'pageUrl': instance.pageUrl,
};
