// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatedToken _$CreatedTokenFromJson(Map<String, dynamic> json) => CreatedToken(
  token: json['token'] as String,
  schema: json[r'$schema'] as String?,
  info: json['info'] == null
      ? null
      : Token.fromJson(json['info'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreatedTokenToJson(CreatedToken instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'info': instance.info,
      'token': instance.token,
    };
