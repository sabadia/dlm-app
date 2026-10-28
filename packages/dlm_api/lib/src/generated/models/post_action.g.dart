// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostAction _$PostActionFromJson(Map<String, dynamic> json) => PostAction(
  kind: json['kind'] as String,
  params: (json['params'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$PostActionToJson(PostAction instance) =>
    <String, dynamic>{'kind': instance.kind, 'params': instance.params};
