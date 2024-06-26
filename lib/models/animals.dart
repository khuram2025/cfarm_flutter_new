import 'package:flutter/material.dart';

const String baseUrl = 'http://farmapp.channab.com';

class Animal {
final int id;
final String tag;
final DateTime dob;
final double? latestWeight;
final String animalType;
final String status;
final String sex;
final String categoryTitle;
final double? purchaseCost;
final String? imagePath;


Animal({
required this.id,
required this.tag,
required this.dob,
this.latestWeight,
required this.animalType,
required this.status,
required this.sex,
required this.categoryTitle,
this.purchaseCost,
this.imagePath,
});

factory Animal.fromJson(Map<String, dynamic> json) {
String? imagePath = json['image'] as String?;
String fullImagePath = imagePath != null && imagePath.isNotEmpty && !imagePath.startsWith('http')
? baseUrl + imagePath
    : imagePath ?? '';

return Animal(
id: json['id'] ?? 0,
tag: json['tag'] ?? 'Unknown',
dob: DateTime.parse(json['dob'] ?? '1900-01-01'),
latestWeight: json['latest_weight'] != null
? double.tryParse(json['latest_weight'].toString())
    : null,
animalType: json['animal_type'] ?? 'Unknown',
status: json['status'] ?? 'Unknown',
sex: json['sex'] ?? 'Unknown',
categoryTitle: json['category_title'] ?? 'Unknown',
purchaseCost: json['purchase_cost'] != null
? double.tryParse(json['purchase_cost'].toString())
    : null,
imagePath: fullImagePath,
);
}
}





class AnimalWeightRecord {
  final String animalTag;
  final double weightKg;
  final String date;
  final String? description;

  AnimalWeightRecord({
    required this.animalTag,
    required this.weightKg,
    required this.date,
    this.description,
  });

  factory AnimalWeightRecord.fromJson(Map<String, dynamic> json) {
    return AnimalWeightRecord(
      animalTag: json['animal']['tag'],
      weightKg: double.parse(json['weight_kg']),
      date: json['date'],
      description: json['description'],
    );
  }
}



class MilkRecord {
  final int animalId;
  final String date;
  final double firstTime;
  final double secondTime;
  final double thirdTime;
  final double totalMilk;

  MilkRecord({
    required this.animalId,
    required this.date,
    required this.firstTime,
    required this.secondTime,
    required this.thirdTime,
    required this.totalMilk,
  });

  factory MilkRecord.fromJson(Map<String, dynamic> json) {
    return MilkRecord(
      animalId: json['animal'],
      date: json['date'],
      firstTime: double.parse(json['first_time']),
      secondTime: double.parse(json['second_time']),
      thirdTime: double.parse(json['third_time']),
      totalMilk: double.parse(json['total_milk']),
    );
  }

  String get animalTag => 'Animal $animalId'; // Mocking the tag since it's not provided
}


