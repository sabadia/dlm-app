// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingBody _$PairingBodyFromJson(Map<String, dynamic> json) => PairingBody(
  schema: json[r'$schema'] as String?,
  browser: json['browser'] == null
      ? null
      : PairingBodyBrowser.fromJson(json['browser'] as String),
  clientId: json['clientId'] as String?,
  name: json['name'] as String?,
  version: json['version'] as String?,
);

Map<String, dynamic> _$PairingBodyToJson(PairingBody instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'browser': _$PairingBodyBrowserEnumMap[instance.browser],
      'clientId': instance.clientId,
      'name': instance.name,
      'version': instance.version,
    };

const _$PairingBodyBrowserEnumMap = {
  PairingBodyBrowser.chrome: 'chrome',
  PairingBodyBrowser.chromium: 'chromium',
  PairingBodyBrowser.edge: 'edge',
  PairingBodyBrowser.brave: 'brave',
  PairingBodyBrowser.opera: 'opera',
  PairingBodyBrowser.vivaldi: 'vivaldi',
  PairingBodyBrowser.firefox: 'firefox',
  PairingBodyBrowser.other: 'other',
  PairingBodyBrowser.$unknown: r'$unknown',
};
