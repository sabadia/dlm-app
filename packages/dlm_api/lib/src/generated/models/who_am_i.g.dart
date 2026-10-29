// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'who_am_i.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhoAmI _$WhoAmIFromJson(Map<String, dynamic> json) => WhoAmI(
  local: json['local'] as bool,
  name: json['name'] as String,
  primary: json['primary'] as bool,
  scope: WhoAmIScope.fromJson(json['scope'] as String),
  tls: json['tls'] as bool,
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$WhoAmIToJson(WhoAmI instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'local': instance.local,
  'name': instance.name,
  'primary': instance.primary,
  'scope': _$WhoAmIScopeEnumMap[instance.scope]!,
  'tls': instance.tls,
};

const _$WhoAmIScopeEnumMap = {
  WhoAmIScope.admin: 'admin',
  WhoAmIScope.read: 'read',
  WhoAmIScope.$unknown: r'$unknown',
};
