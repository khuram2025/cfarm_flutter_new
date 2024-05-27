class Field {
  final int id;
  final String name;
  final double area;
  final String? imageUrl;

  Field({
    required this.id,
    required this.name,
    required this.area,
    this.imageUrl,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'],
      name: json['name'],
      area: double.parse(json['area']),
      imageUrl: json['image'],
    );
  }
}


class Crop {
  final int id;
  final String name;
  final String variety;
  final String plantingDate;
  final String stage;
  final String? fieldImageUrl;

  Crop({
    required this.id,
    required this.name,
    required this.variety,
    required this.plantingDate,
    required this.stage,
    this.fieldImageUrl,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      name: json['name'],
      variety: json['variety'] ?? '',
      plantingDate: json['planting_date'],
      stage: json['stage'],
      fieldImageUrl: json['field_image_url'],
    );
  }
}
