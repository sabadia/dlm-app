// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'browser_profiles.g.dart';

@JsonSerializable()
class BrowserProfiles {
  const BrowserProfiles({required this.profiles, this.schema});

  factory BrowserProfiles.fromJson(Map<String, Object?> json) =>
      _$BrowserProfilesFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Site groups that have a browser profile.
  final List<String>? profiles;

  Map<String, Object?> toJson() => _$BrowserProfilesToJson(this);
}
