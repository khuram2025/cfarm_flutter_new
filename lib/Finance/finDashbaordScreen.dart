import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  late Future<List<Transaction>> _transactionsFuture;
  DateTime _selectedDate = DateTime(2024, 5);
  Map<String, Color> _categoryColors = {};
  final List<Color> _availableColors = [
    Color(0xFF0DA487),
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.red,
    Colors.brown,
    Colors.cyan,
  ];
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  void _fetchTransactions() {
    setState(() {
      _transactionsFuture = fetchTransactions();
    });
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

      // Assign colors dynamically to categories
      allTransactions.forEach((transaction) {
        if (!_categoryColors.containsKey(transaction.category)) {
          _categoryColors[transaction.category] = _getNextColor();
        }
      });

      return allTransactions.take(10).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Color _getNextColor() {
    Color color = _availableColors[_colorIndex % _availableColors.length];
    _colorIndex++;
    return color;
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
                          style: TextStyle(color: Colors.green, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\$6,000',
                          style: TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
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
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\$2,000',
                          style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      series: <CartesianSeries>[
                        LineSeries<SalesData, String>(
                          color: Colors.green,
                          dataSource: getChartData(),
                          xValueMapper: (SalesData sales, _) => sales.month,
                          yValueMapper: (SalesData sales, _) => sales.income,
                          name: 'Income',
                        ),
                        LineSeries<SalesData, String>(
                          color: Colors.red,
                          dataSource: getChartData(),
                          xValueMapper: (SalesData sales, _) => sales.month,
                          yValueMapper: (SalesData sales, _) => sales.expense,
                          name: 'Expenses',
                        ),
                      ],
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
                    return ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return Column(
                          children: [
                            _buildTransactionItem(
                              context,
                              transaction.category,
                              DateFormat('yyyy-MM-dd').format(transaction.date),
                              'Rs. ${transaction.amount}',
                              transaction.description,
                            ),
                            Divider(),
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

  List<SalesData> getChartData() {
    return [
      SalesData('Jan', 400, 300),
      SalesData('Feb', 500, 400),
      SalesData('Mar', 600, 200),
      SalesData('Apr', 700, 600),
      SalesData('May', 400, 300),
      SalesData('Jun', 500, 400),
      SalesData('Jul', 600, 200),
    ];
  }

  Widget _buildTransactionItem(BuildContext context, String category, String date, String amount, String description) {
    Color categoryColor = _categoryColors[category] ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                amount,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Transaction Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                              Divider(),
                              Text(
                                'Category: $category',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Date: $date',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Amount: $amount',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              if (description.isNotEmpty)
                                Text(
                                  'Description: $description',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Options: ',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Handle Edit click
                                    },
                                    child: Text(
                                      'Edit',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Handle Delete click
                                    },
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text(
                  'Details',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.month, this.income, this.expense);
  final String month;
  final double income;
  final double expense;
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
      amount: double.parse(json['amount'].toString()), // Ensure amount is parsed as double
      category: json['category'],
      description: json['description'] ?? '',
    );
  }
}
