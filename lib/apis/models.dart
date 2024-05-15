class Animal {
  final int id;
  final String tag;
  final DateTime dob;
  final double? latestWeight; // latestWeight can be null
  final String animalType;
  final String status;
  final String sex;
  final String categoryTitle;
  final double? purchaseCost; // purchaseCost can be null
  final String? imagePath; // imagePath can be null

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
    String baseUrl = 'http://farmapp.channab.com';
    String imagePath = json['image'] as String? ?? '';
    String fullImagePath = imagePath.isNotEmpty ? baseUrl + imagePath : 'default_image_url_here';
    return Animal(
      id: json['id'] ?? 0,  // Assuming 0 as a default id, or handle appropriately
      tag: json['tag'] ?? 'Unknown',  // Providing a default value if tag is null
      dob: DateTime.parse(json['dob'] ?? '1900-01-01'),  // Default to a fallback date
      latestWeight: json['latest_weight'] != null ? double.tryParse(json['latest_weight'].toString()) : null,
      animalType: json['animal_type'] ?? 'Unknown',  // Default type
      status: json['status'] ?? 'Unknown',  // Default status
      sex: json['sex'] ?? 'Unknown',  // Default sex
      categoryTitle: json['category_title'] ?? 'Unknown',  // Default category title
      purchaseCost: json['purchase_cost'] != null ? double.tryParse(json['purchase_cost'].toString()) : null,
      imagePath: fullImagePath,
    );
  }


}

class MilkingData {
  final DateTime date;
  final double firstMilking;
  final double secondMilking;
  final double thirdMilking;

  MilkingData(this.date, this.firstMilking, this.secondMilking, this.thirdMilking);

  factory MilkingData.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      try {
        return double.parse(value?.toString() ?? '0.0');
      } catch (e) {
        print("Error parsing double: $e");
        return 0.0;
      }
    }

    return MilkingData(
      DateTime.parse(json['date']),
      parseDouble(json['first_time']),
      parseDouble(json['second_time']),
      parseDouble(json['third_time']),
    );
  }


  double get total => firstMilking + secondMilking + thirdMilking;
}

class MilkingRecord {
  final DateTime date;
  final double? firstTime;
  final double? secondTime;
  final double? thirdTime;
  final double totalMilk;
  final double? firstTimeDiff;
  final double? secondTimeDiff;
  final double? thirdTimeDiff;
  final double? totalDiff;

  MilkingRecord({
    required this.date,
    this.firstTime,
    this.secondTime,
    this.thirdTime,
    required this.totalMilk,
    this.firstTimeDiff,
    this.secondTimeDiff,
    this.thirdTimeDiff,
    this.totalDiff,
  });

  factory MilkingRecord.fromJson(Map<String, dynamic> json) {
    return MilkingRecord(
      date: DateTime.parse(json['date']),
      firstTime: json['first_time'] != null ? double.tryParse(json['first_time'].toString()) : null,
      secondTime: json['second_time'] != null ? double.tryParse(json['second_time'].toString()) : null,
      thirdTime: json['third_time'] != null ? double.tryParse(json['third_time'].toString()) : null,
      totalMilk: json['total_milk'] != null ? double.tryParse(json['total_milk'].toString()) ?? 0.0 : 0.0,
      // Include the other fields if they exist in the JSON
      firstTimeDiff: json['first_time_diff'] != null ? double.tryParse(json['first_time_diff'].toString()) : null,
      secondTimeDiff: json['second_time_diff'] != null ? double.tryParse(json['second_time_diff'].toString()) : null,
      thirdTimeDiff: json['third_time_diff'] != null ? double.tryParse(json['third_time_diff'].toString()) : null,
      totalDiff: json['total_diff'] != null ? double.tryParse(json['total_diff'].toString()) : null,
    );
  }




}


class Expense {
  final int id;
  final String date;
  final String amount;
  final String category;
  final String description;

  Expense({
    required this.id,
    required this.date,
    required this.amount,
    required this.category,
    required this.description,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      date: json['date'],
      amount: json['amount'],
      category: json['category']['name'],
      description: json['description'],
    );
  }
}

