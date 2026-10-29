// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressData _$ProgressDataFromJson(Map<String, dynamic> json) => ProgressData(
  connections: (json['connections'] as num).toInt(),
  downloaded: (json['downloaded'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  speed: (json['speed'] as num).toInt(),
  peers: (json['peers'] as num?)?.toInt(),
  uploadSpeed: (json['uploadSpeed'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProgressDataToJson(ProgressData instance) =>
    <String, dynamic>{
      'connections': instance.connections,
      'downloaded': instance.downloaded,
      'peers': instance.peers,
      'size': instance.size,
      'speed': instance.speed,
      'uploadSpeed': instance.uploadSpeed,
    };
