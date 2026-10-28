// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'installation.g.dart';

@JsonSerializable()
class Installation {
  const Installation({required this.name, required this.path, this.version});

  factory Installation.fromJson(Map<String, Object?> json) =>
      _$InstallationFromJson(json);

  final String name;
  final String path;
  final String? version;

  Map<String, Object?> toJson() => _$InstallationToJson(this);
}
