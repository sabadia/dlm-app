// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'proxy.g.dart';

@JsonSerializable()
class Proxy {
  const Proxy({required this.mode, this.url});

  factory Proxy.fromJson(Map<String, Object?> json) => _$ProxyFromJson(json);

  final String mode;
  final String? url;

  Map<String, Object?> toJson() => _$ProxyToJson(this);
}
