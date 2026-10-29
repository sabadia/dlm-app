// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PluginList _$PluginListFromJson(Map<String, dynamic> json) => PluginList(
  plugins: (json['plugins'] as List<dynamic>?)
      ?.map((e) => Plugin.fromJson(e as Map<String, dynamic>))
      .toList(),
  schema: json[r'$schema'] as String?,
);

Map<String, dynamic> _$PluginListToJson(PluginList instance) =>
    <String, dynamic>{r'$schema': instance.schema, 'plugins': instance.plugins};
