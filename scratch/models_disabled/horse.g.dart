// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Horse _$HorseFromJson(Map<String, dynamic> json) => Horse(
      id: json['id'] as String,
      name: json['name'] as String,
      breed: json['breed'] as String,
      age: (json['age'] as num).toInt(),
      color: json['color'] as String,
      gender: json['gender'] as String,
      microchip: json['microchip'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HorseToJson(Horse instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'breed': instance.breed,
      'age': instance.age,
      'color': instance.color,
      'gender': instance.gender,
      'microchip': instance.microchip,
      'images': instance.images,
    };
