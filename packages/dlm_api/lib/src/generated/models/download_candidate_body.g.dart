// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_candidate_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadCandidateBody _$DownloadCandidateBodyFromJson(
  Map<String, dynamic> json,
) => DownloadCandidateBody(
  schema: json[r'$schema'] as String?,
  dir: json['dir'] as String?,
  labels: (json['labels'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  name: json['name'] as String?,
  paused: json['paused'] as bool?,
  priority: json['priority'] == null
      ? null
      : DownloadCandidateBodyPriority.fromJson(json['priority'] as String),
  queueId: json['queueId'] as String?,
  settings: json['settings'] == null
      ? null
      : Settings.fromJson(json['settings'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DownloadCandidateBodyToJson(
  DownloadCandidateBody instance,
) => <String, dynamic>{
  r'$schema': instance.schema,
  'dir': instance.dir,
  'labels': instance.labels,
  'name': instance.name,
  'paused': instance.paused,
  'priority': _$DownloadCandidateBodyPriorityEnumMap[instance.priority],
  'queueId': instance.queueId,
  'settings': instance.settings,
};

const _$DownloadCandidateBodyPriorityEnumMap = {
  DownloadCandidateBodyPriority.low: 'low',
  DownloadCandidateBodyPriority.normal: 'normal',
  DownloadCandidateBodyPriority.high: 'high',
  DownloadCandidateBodyPriority.$unknown: r'$unknown',
};
