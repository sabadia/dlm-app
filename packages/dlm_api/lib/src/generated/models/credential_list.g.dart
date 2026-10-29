// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CredentialList _$CredentialListFromJson(Map<String, dynamic> json) =>
    CredentialList(
      credentials: (json['credentials'] as List<dynamic>?)
          ?.map((e) => Credential.fromJson(e as Map<String, dynamic>))
          .toList(),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$CredentialListToJson(CredentialList instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'credentials': instance.credentials,
    };
