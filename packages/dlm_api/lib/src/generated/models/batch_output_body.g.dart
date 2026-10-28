// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_output_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BatchOutputBody _$BatchOutputBodyFromJson(Map<String, dynamic> json) =>
    BatchOutputBody(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => BatchItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      schema: json[r'$schema'] as String?,
    );

Map<String, dynamic> _$BatchOutputBodyToJson(BatchOutputBody instance) =>
    <String, dynamic>{r'$schema': instance.schema, 'results': instance.results};
