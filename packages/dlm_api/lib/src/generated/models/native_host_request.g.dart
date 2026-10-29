// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native_host_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NativeHostRequest _$NativeHostRequestFromJson(Map<String, dynamic> json) =>
    NativeHostRequest(
      action: NativeHostRequestAction.fromJson(json['action'] as String),
      schema: json[r'$schema'] as String?,
      browsers: (json['browsers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      extensionIds: (json['extensionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      firefoxIds: (json['firefoxIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$NativeHostRequestToJson(NativeHostRequest instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'action': _$NativeHostRequestActionEnumMap[instance.action]!,
      'browsers': instance.browsers,
      'extensionIds': instance.extensionIds,
      'firefoxIds': instance.firefoxIds,
    };

const _$NativeHostRequestActionEnumMap = {
  NativeHostRequestAction.install: 'install',
  NativeHostRequestAction.uninstall: 'uninstall',
  NativeHostRequestAction.$unknown: r'$unknown',
};
