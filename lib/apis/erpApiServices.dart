import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/erpModels.dart';
import 'models.dart';

class ApiService {
  static Future<List<SummaryData>> fetchSummaryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final url = 'http://farmapp.channab.com/erp/api/income-expense-summary/';

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
      throw Exception('Failed to load summary data');
    }
  }

  static Future<List<Transaction>> fetchTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final incomeUrl = 'http://farmapp.channab.com/erp/api/income/';
    final expensesUrl = 'http://farmapp.channab.com/erp/api/expenses/';

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
      List<dynamic> incomeJson = json.decode(incomeResponse.body) as List;
      List<dynamic> expensesJson = json.decode(expensesResponse.body) as List;

      List<Transaction> incomeTransactions = incomeJson.map((json) => Transaction.fromJson(json, true)).toList();
      List<Transaction> expensesTransactions = expensesJson.map((json) => Transaction.fromJson(json, false)).toList();

      incomeTransactions = incomeTransactions.take(5).toList();
      expensesTransactions = expensesTransactions.take(5).toList();

      List<Transaction> allTransactions = []
        ..addAll(incomeTransactions)
        ..addAll(expensesTransactions);

      allTransactions.sort((a, b) => b.date.compareTo(a.date));

      return allTransactions.take(10).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }
}
