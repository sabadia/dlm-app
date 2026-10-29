// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryMatch _$CategoryMatchFromJson(Map<String, dynamic> json) =>
    CategoryMatch(
      schema: json[r'$schema'] as String?,
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CategoryMatchToJson(CategoryMatch instance) =>
    <String, dynamic>{
      r'$schema': instance.schema,
      'category': instance.category,
    };
