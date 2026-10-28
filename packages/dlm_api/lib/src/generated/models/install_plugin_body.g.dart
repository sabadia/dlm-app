// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'install_plugin_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstallPluginBody _$InstallPluginBodyFromJson(Map<String, dynamic> json) =>
    InstallPluginBody(
      source: json['source'] as String,
      schema: json[r'$schema'] as String?,
      disabled: json['disabled'] as bool?,
      ref: json['ref'] as String?,
      replace: json['replace'] as bool?,
    );

Map<String, dynamic> _$InstallPluginBodyToJson(InstallPluginBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'disabled': instance.disabled,
      'ref': instance.ref,
      'replace': instance.replace,
      'source': instance.source,
    };
