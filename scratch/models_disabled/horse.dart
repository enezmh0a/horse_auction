import 'package:json_annotation/json_annotation.dart';

part 'horse.g.dart';

@JsonSerializable()
class Horse {
  final String id;
  final String name;
  final String breed;
  final int age;               // years
  final String color;
  final String gender;         // Stallion/Mare/Gelding
  final String microchip;
  final List<String> images;   // URLs

  Horse({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.color,
    required this.gender,
    required this.microchip,
    this.images = const [],
  });

  factory Horse.fromJson(Map<String, dynamic> json) => _$HorseFromJson(json);
  Map<String, dynamic> toJson() => _$HorseToJson(this);
}
