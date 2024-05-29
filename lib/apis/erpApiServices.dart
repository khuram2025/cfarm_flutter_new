import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/erpModels.dart';
import 'models.dart';

class ApiService {
  static Future<List<SummaryData>> fetchSummaryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final url = 'http://192.168.8.153/erp/api/income-expense-summary/';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> summaryJson = json.decode(response.body) as List;
      return summaryJson.map((json) => SummaryData.fromJson(json)).toList();
    } else {
      print('Failed to load data: ${response.body}'); // Print the error response
      throw Exception('Failed to load summary data');
    }
  }

  static Future<List<Transaction>> fetchTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final incomeUrl = 'http://192.168.8.153/erp/api/current-month-income-summary/';
    final expensesUrl = 'http://192.168.8.153/erp/api/current-month-expense-summary/';

    final incomeResponse = await http.get(
      Uri.parse(incomeUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    final expensesResponse = await http.get(
      Uri.parse(expensesUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (incomeResponse.statusCode == 200 && expensesResponse.statusCode == 200) {
      List<dynamic> incomeJson = json.decode(incomeResponse.body)['category_incomes'];
      List<dynamic> expensesJson = json.decode(expensesResponse.body)['category_expenses'];

      List<Transaction> incomeTransactions = incomeJson.map((json) => Transaction.fromJson(json, true)).toList();
      List<Transaction> expensesTransactions = expensesJson.map((json) => Transaction.fromJson(json, false)).toList();

      List<Transaction> allTransactions = []
        ..addAll(incomeTransactions)
        ..addAll(expensesTransactions);

      return allTransactions;
    } else {
      throw Exception('Failed to load transactions');
    }
  }
}
