class Note {
  final int id;
  final int crop;
  final String description;
  final String creationDate;
  final String? image;

  Note({
    required this.id,
    required this.crop,
    required this.description,
    required this.creationDate,
    this.image,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      crop: json['crop'],
      description: json['description'],
      creationDate: json['creation_date'],
      image: json['image'],
    );
  }
}



class Harvest {
  final int id;
  final int crop;
  final DateTime startDate;
  final DateTime? endDate;
  final double? production;
  final String unit;
  final int cutNumber;

  Harvest({
    required this.id,
    required this.crop,
    required this.startDate,
    this.endDate,
    this.production,
    required this.unit,
    required this.cutNumber,
  });

  factory Harvest.fromJson(Map<String, dynamic> json) {
    return Harvest(
      id: json['id'],
      crop: json['crop'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      production: json['production'] != null ? json['production'].toDouble() : null,
      unit: json['unit'],
      cutNumber: json['cut_number'],
    );
  }
}