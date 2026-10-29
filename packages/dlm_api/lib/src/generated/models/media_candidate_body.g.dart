// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_candidate_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaCandidateBody _$MediaCandidateBodyFromJson(Map<String, dynamic> json) =>
    MediaCandidateBody(
      url: json['url'] as String,
      kind: json['kind'] == null
          ? null
          : MediaCandidateBodyKind.fromJson(json['kind'] as String),
      mime: json['mime'] as String?,
      size: (json['size'] as num?)?.toInt(),
      variant: json['variant'] as String?,
    );

Map<String, dynamic> _$MediaCandidateBodyToJson(MediaCandidateBody instance) =>
    <String, dynamic>{
      'kind': _$MediaCandidateBodyKindEnumMap[instance.kind],
      'mime': instance.mime,
      'size': instance.size,
      'url': instance.url,
      'variant': instance.variant,
    };

const _$MediaCandidateBodyKindEnumMap = {
  MediaCandidateBodyKind.hls: 'hls',
  MediaCandidateBodyKind.dash: 'dash',
  MediaCandidateBodyKind.video: 'video',
  MediaCandidateBodyKind.audio: 'audio',
  MediaCandidateBodyKind.file: 'file',
  MediaCandidateBodyKind.$unknown: r'$unknown',
};
