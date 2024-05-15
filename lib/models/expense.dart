import 'package:flutter/material.dart';

// models/expense.dart
class Expense {
  final int id;
  final DateTime date;
  final double amount;
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
    // print("Parsing expense: $json"); // Print the received JSON data
    return Expense(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: double.parse(json['amount']),
      category: json['category'],
      description: json['description'],
    );
  }
}

// filter_model.dart
class FilterModel {
  final String type;
  final String category;
  final RangeValues amountRange;
  final String dateFilter;
  final DateTimeRange? customDateRange;

  FilterModel({
    required this.type,
    required this.category,
    required this.amountRange,
    required this.dateFilter,
    this.customDateRange,
  });
}
