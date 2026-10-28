// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_profiles.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrowserProfiles _$BrowserProfilesFromJson(Map<String, dynamic> json) =>
    BrowserProfiles(
      profiles: (json['profiles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$BrowserProfilesToJson(BrowserProfiles instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'profiles': instance.profiles,
    };
