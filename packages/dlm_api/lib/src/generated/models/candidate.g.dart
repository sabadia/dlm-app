// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Candidate _$CandidateFromJson(Map<String, dynamic> json) => Candidate(
  foundAt: DateTime.parse(json['foundAt'] as String),
  index: (json['index'] as num).toInt(),
  kind: json['kind'] as String,
  size: (json['size'] as num).toInt(),
  source: json['source'] as String,
  url: json['url'] as String,
  file: json['file'] as String?,
  filename: json['filename'] as String?,
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  mime: json['mime'] as String?,
  page: json['page'] as String?,
);

Map<String, dynamic> _$CandidateToJson(Candidate instance) => <String, dynamic>{
  'file': instance.file,
  'filename': instance.filename,
  'foundAt': instance.foundAt.toIso8601String(),
  'headers': instance.headers,
  'index': instance.index,
  'kind': instance.kind,
  'mime': instance.mime,
  'page': instance.page,
  'size': instance.size,
  'source': instance.source,
  'url': instance.url,
};
