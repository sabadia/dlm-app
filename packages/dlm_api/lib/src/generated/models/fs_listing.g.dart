// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs_listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FsListing _$FsListingFromJson(Map<String, dynamic> json) => FsListing(
  entries: (json['entries'] as List<dynamic>?)
      ?.map((e) => FsEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  path: json['path'] as String,
  schema: json[r'$schema'] as String?,
  parent: json['parent'] as String?,
  truncated: json['truncated'] as bool?,
);

Map<String, dynamic> _$FsListingToJson(FsListing instance) => <String, dynamic>{
  r'$schema': instance.schema,
  'entries': instance.entries,
  'parent': instance.parent,
  'path': instance.path,
  'truncated': instance.truncated,
};
