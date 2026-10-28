// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fingerprint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fingerprint _$FingerprintFromJson(Map<String, dynamic> json) => Fingerprint(
  size: (json['size'] as num).toInt(),
  contentType: json['contentType'] as String?,
  etag: json['etag'] as String?,
  filename: json['filename'] as String?,
  lastModified: json['lastModified'] == null
      ? null
      : DateTime.parse(json['lastModified'] as String),
);

Map<String, dynamic> _$FingerprintToJson(Fingerprint instance) =>
    <String, dynamic>{
      'contentType': instance.contentType,
      'etag': instance.etag,
      'filename': instance.filename,
      'lastModified': instance.lastModified?.toIso8601String(),
      'size': instance.size,
    };
