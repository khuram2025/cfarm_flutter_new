// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

Future<List<Expense>> fetchExpenses() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  final response = await http.get(
    Uri.parse('http://192.168.8.153/erp/api/expenses/'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Token $token",
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> expensesJson = json.decode(response.body) as List;
    return expensesJson.map((json) => Expense.fromJson(json)).toList();
  } else {
    print('Failed to load expenses with status code: ${response.statusCode}');
    throw Exception('Failed to load expenses with status code: ${response.statusCode}');
  }
}


Future<List<String>> fetchCategories() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  final response = await http.get(
    Uri.parse('http://192.168.8.153/erp/api/expenses/categories/'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Token $token",
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> categoriesJson = json.decode(response.body) as List;
    List<String> categories = categoriesJson.map((json) => json['name'] as String).toList();

    // Filter out categories with names like "Salery" or "salery"
    categories = categories.where((category) => category.toLowerCase() != 'salary').toList();

    return categories;
  } else {
    throw Exception('Failed to load categories');
  }
}


Future<List<String>> fetchIncomeCategories() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  final response = await http.get(
    Uri.parse('http://192.168.8.153/erp/api/income/categories/'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Token $token",
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> categoriesJson = json.decode(response.body) as List;
    List<String> categories = categoriesJson.map((json) => json['name'] as String).toList();
    return categories;
  } else {
    throw Exception('Failed to load categories');
  }
}



