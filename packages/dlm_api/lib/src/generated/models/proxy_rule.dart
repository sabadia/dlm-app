// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'proxy.dart';

part 'proxy_rule.g.dart';

@JsonSerializable()
class ProxyRule {
  const ProxyRule({required this.hosts, required this.proxy});

  factory ProxyRule.fromJson(Map<String, Object?> json) =>
      _$ProxyRuleFromJson(json);

  final List<String>? hosts;
  final Proxy proxy;

  Map<String, Object?> toJson() => _$ProxyRuleToJson(this);
}
