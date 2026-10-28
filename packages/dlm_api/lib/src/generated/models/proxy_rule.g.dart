// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProxyRule _$ProxyRuleFromJson(Map<String, dynamic> json) => ProxyRule(
  hosts: (json['hosts'] as List<dynamic>?)?.map((e) => e as String).toList(),
  proxy: Proxy.fromJson(json['proxy'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProxyRuleToJson(ProxyRule instance) => <String, dynamic>{
  'hosts': instance.hosts,
  'proxy': instance.proxy,
};
