import 'package:flutter/material.dart';

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
    return Expense(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: double.parse(json['amount']),
      category: json['category'],
      description: json['description'] ?? '',
    );
  }
}

class Transaction {
  final int id;
  final DateTime date;
  final double amount;
  final String category;
  final String description;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.category,
    required this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: double.parse(json['amount']),
      category: json['category'],
      description: json['description'] ?? '',
    );
  }
}

// filter_model.dart
class FilterModel {
  String type;
  String category;
  RangeValues amountRange;
  String dateFilter;
  DateTimeRange? customDateRange;

  FilterModel({
    required this.type,
    required this.category,
    required this.amountRange,
    required this.dateFilter,
    this.customDateRange,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'category': category,
      'amountRange': {
        'start': amountRange.start,
        'end': amountRange.end,
      },
      'dateFilter': dateFilter,
      'customDateRange': customDateRange != null
          ? {
        'start': customDateRange!.start.toIso8601String(),
        'end': customDateRange!.end.toIso8601String(),
      }
          : null,
    };
  }
}
