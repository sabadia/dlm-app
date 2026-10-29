// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_token_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTokenBody _$CreateTokenBodyFromJson(Map<String, dynamic> json) =>
    CreateTokenBody(
      name: json['name'] as String,
      scope: CreateTokenBodyScope.fromJson(json['scope'] as String),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$CreateTokenBodyToJson(CreateTokenBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'name': instance.name,
      'scope': _$CreateTokenBodyScopeEnumMap[instance.scope]!,
    };

const _$CreateTokenBodyScopeEnumMap = {
  CreateTokenBodyScope.admin: 'admin',
  CreateTokenBodyScope.read: 'read',
  CreateTokenBodyScope.$unknown: r'$unknown',
};
