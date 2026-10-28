// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_plugin_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePluginBody _$UpdatePluginBodyFromJson(Map<String, dynamic> json) =>
    UpdatePluginBody(
      schema: json[r'$schema'] as String?,
      enabled: json['enabled'] as bool?,
    );

Map<String, dynamic> _$UpdatePluginBodyToJson(UpdatePluginBody instance) =>
    <String, dynamic>{r'$schema': instance.schema, 'enabled': instance.enabled};
