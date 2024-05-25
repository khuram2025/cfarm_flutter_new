import 'package:flutter/material.dart';

const String baseUrl = 'https://farm.channab.com';

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
