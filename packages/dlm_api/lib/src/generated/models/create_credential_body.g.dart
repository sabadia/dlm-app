// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_credential_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCredentialBody _$CreateCredentialBodyFromJson(
  Map<String, dynamic> json,
) => CreateCredentialBody(
  host: json['host'] as String,
  password: json['password'] as String,
  username: json['username'] as String,
  schema: json[r'$schema'] as String?,
  scheme: json['scheme'] == null
      ? null
      : CreateCredentialBodyScheme.fromJson(json['scheme'] as String),
);

Map<String, dynamic> _$CreateCredentialBodyToJson(
  CreateCredentialBody instance,
) => <String, dynamic>{
  r'$schema': instance.schema,
  'host': instance.host,
  'password': instance.password,
  'scheme': _$CreateCredentialBodySchemeEnumMap[instance.scheme],
  'username': instance.username,
};

const _$CreateCredentialBodySchemeEnumMap = {
  CreateCredentialBodyScheme.auto: 'auto',
  CreateCredentialBodyScheme.basic: 'basic',
  CreateCredentialBodyScheme.digest: 'digest',
  CreateCredentialBodyScheme.$unknown: r'$unknown',
};
