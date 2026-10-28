// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'install_plugin_body.g.dart';

@JsonSerializable()
class InstallPluginBody {
  const InstallPluginBody({
    required this.source,
    this.schema,
    this.disabled,
    this.ref,
    this.replace,
  });

  factory InstallPluginBody.fromJson(Map<String, Object?> json) =>
      _$InstallPluginBodyFromJson(json);

  /// A URL to the JSON Schema for this object.
  /// Incorrect name has been replaced. Original name: `$schema`.
  @JsonKey(name: '\$schema')
  final String? schema;

  /// Install the plugin switched off.
  final bool? disabled;

  /// Branch or tag of a git source.
  final String? ref;

  /// Upgrade an installed plugin of the same name instead of refusing with 409.
  final bool? replace;

  /// An absolute directory on the daemon's host holding manifest.json and the script, or an https:// git URL (needs git on the daemon's PATH).
  final String source;

  Map<String, Object?> toJson() => _$InstallPluginBodyToJson(this);
}
