import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled3/Finance/transactionsScreen.dart';

import '../models/expense.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AnalyticsScreen(),
    );
  }
}

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final Color primaryColor = Color(0xFF0DA487);
  late Future<List<SummaryData>> _summaryDataFuture;
  late Future<List<Transaction>> _transactionsFuture;
  DateTime _selectedDate = DateTime(2024, 5);
  Map<String, Color> _categoryColors = {};

  int _colorIndex = 0;

  double totalIncome = 0;
  double totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _fetchSummaryData();
    _fetchTransactions();
  }

  void _fetchSummaryData() {
    setState(() {
      _summaryDataFuture = fetchSummaryData();
      _summaryDataFuture.then((data) {
        DateTime now = DateTime.now();
        String currentMonth = DateFormat('MMM yyyy').format(now);
        for (var summary in data) {
          if (summary.month == currentMonth) {
            setState(() {
              totalIncome = summary.totalIncome;
              totalExpense = summary.totalExpense;
            });
            break;
          }
        }
      });
    });
  }

  void _fetchTransactions() {
    setState(() {
      _transactionsFuture = fetchTransactions();
    });
  }

  Future<List<SummaryData>> fetchSummaryData() async {
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

  Future<List<Transaction>> fetchTransactions() async {
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

      List<Transaction> incomeTransactions = incomeJson.map((json) => Transaction.fromJson(json)).toList();
      List<Transaction> expensesTransactions = expensesJson.map((json) => Transaction.fromJson(json)).toList();

      // Take the latest 5 transactions from each
      incomeTransactions = incomeTransactions.take(5).toList();
      expensesTransactions = expensesTransactions.take(5).toList();

      List<Transaction> allTransactions = []
        ..addAll(incomeTransactions)
        ..addAll(expensesTransactions);

      // Sort transactions by date
      allTransactions.sort((a, b) => b.date.compareTo(a.date));



      return allTransactions.take(10).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }



  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fetchSummaryData();
        _fetchTransactions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _selectDate(context),
            child: Text(
              DateFormat('MMMM yyyy').format(_selectedDate),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionPageWidget(isIncome: true),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Income',
                            style: TextStyle(color: Colors.green, fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${totalIncome.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.green, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionPageWidget(isIncome: false),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Expenses',
                            style: TextStyle(color: Colors.red, fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${totalExpense.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.red, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comparison Chart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: FutureBuilder<List<SummaryData>>(
                      future: _summaryDataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Failed to load summary data: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('No data available.'));
                        } else {
                          final summaryData = snapshot.data!;
                          return SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            primaryYAxis: NumericAxis(
                              numberFormat: NumberFormat.compact(),
                            ),
                            series: <CartesianSeries>[
                              ColumnSeries<SummaryData, String>(
                                color: Colors.green,
                                dataSource: summaryData,
                                xValueMapper: (SummaryData data, _) => data.month,
                                yValueMapper: (SummaryData data, _) => data.totalIncome,
                                name: 'Income',
                              ),
                              ColumnSeries<SummaryData, String>(
                                color: Colors.red,
                                dataSource: summaryData,
                                xValueMapper: (SummaryData data, _) => data.month,
                                yValueMapper: (SummaryData data, _) => data.totalExpense,
                                name: 'Expenses',
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Transaction>>(
                future: _transactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Failed to load transactions: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No transactions found.'));
                  } else {
                    final transactions = snapshot.data!;
                    final categories = _getCategoryTotals(transactions);
                    return ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Column(
                          children: [
                            _buildCategoryItem(
                              context,
                              category['category']!,
                              'Rs. ${category['total']}',
                              category['isIncome'] == 'true',
                            ),
                            Divider(thickness: 1, color: Colors.grey[300]),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getCategoryTotals(List<Transaction> transactions) {
    Map<String, double> categoryTotals = {};
    Map<String, bool> categoryTypes = {};

    for (var transaction in transactions) {
      if (!categoryTotals.containsKey(transaction.category)) {
        categoryTotals[transaction.category] = 0;
        categoryTypes[transaction.category] = transaction.category.contains('Income');
      }
      categoryTotals[transaction.category] = categoryTotals[transaction.category]! + transaction.amount;
    }

    return categoryTotals.entries
        .map((entry) => {
      'category': entry.key,
      'total': entry.value.toString(),
      'isIncome': categoryTypes[entry.key].toString(),
    })
        .toList();
  }

  Widget _buildCategoryItem(BuildContext context, String category, String total, bool isIncome) {
    Color categoryColor = isIncome ? Color(0xFF0DA487) : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              category,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: categoryColor),
            ),
          ),
          Text(
            total,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: categoryColor),
          ),
        ],
      ),
    );
  }
}

class SummaryData {
  SummaryData({required this.month, required this.totalIncome, required this.totalExpense});

  final String month;
  final double totalIncome;
  final double totalExpense;

  factory SummaryData.fromJson(Map<String, dynamic> json) {
    return SummaryData(
      month: json['month'],
      totalIncome: json['total_income'].toDouble(),
      totalExpense: json['total_expense'].toDouble(),
    );
  }
}
