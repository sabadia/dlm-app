// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_credential_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCredentialBody _$UpdateCredentialBodyFromJson(
  Map<String, dynamic> json,
) => UpdateCredentialBody(
  schema: json[r'$schema'] as String?,
  host: json['host'] as String?,
  password: json['password'] as String?,
  scheme: json['scheme'] == null
      ? null
      : UpdateCredentialBodyScheme.fromJson(json['scheme'] as String),
  username: json['username'] as String?,
);

Map<String, dynamic> _$UpdateCredentialBodyToJson(
  UpdateCredentialBody instance,
) => <String, dynamic>{
  r'$schema': instance.schema,
  'host': instance.host,
  'password': instance.password,
  'scheme': _$UpdateCredentialBodySchemeEnumMap[instance.scheme],
  'username': instance.username,
};

const _$UpdateCredentialBodySchemeEnumMap = {
  UpdateCredentialBodyScheme.auto: 'auto',
  UpdateCredentialBodyScheme.basic: 'basic',
  UpdateCredentialBodyScheme.digest: 'digest',
  UpdateCredentialBodyScheme.$unknown: r'$unknown',
};
