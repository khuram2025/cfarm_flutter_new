import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import 'addTransaction.dart';
import 'transactionFilter.dart';
import '../home/customDrawer.dart';
import '../home/customeAppBar.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionPageWidget extends StatefulWidget {
  final bool isIncome;

  const TransactionPageWidget({Key? key, required this.isIncome}) : super(key: key);

  @override
  State<TransactionPageWidget> createState() => _TransactionPageWidgetState();
}

class _TransactionPageWidgetState extends State<TransactionPageWidget> {
  late Future<List<Expense>> _expensesFuture;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  FilterModel? activeFilters;
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
    _fetchExpenses();
  }

  void _fetchExpenses([FilterModel? filters]) {
    setState(() {
      _expensesFuture = fetchExpenses(filters);
      activeFilters = filters;
    });
  }

  Future<List<Expense>> fetchExpenses([FilterModel? filters]) async {
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
      List<Expense> expenses = expensesJson.map((json) => Expense.fromJson(json)).toList();

      if (filters != null) {
        expenses = _applyFilters(expenses, filters);
      }

      // Assign colors dynamically to categories
      expenses.forEach((expense) {
        if (!_categoryColors.containsKey(expense.category)) {
          _categoryColors[expense.category] = _getNextColor();
        }
      });

      return expenses;
    } else {
      print('Failed to load expenses with status code: ${response.statusCode}');
      throw Exception('Failed to load expenses with status code: ${response.statusCode}');
    }
  }

  List<Expense> _applyFilters(List<Expense> expenses, FilterModel filters) {
    if (filters.type != 'All') {
      expenses = expenses.where((expense) => expense.category == filters.type).toList();
    }
    if (filters.category != 'All') {
      expenses = expenses.where((expense) => expense.category == filters.category).toList();
    }
    expenses = expenses.where((expense) => expense.amount >= filters.amountRange.start && expense.amount <= filters.amountRange.end).toList();
    if (filters.dateFilter != 'All') {
      DateTime now = DateTime.now();
      DateTime startDate;
      DateTime endDate;
      switch (filters.dateFilter) {
        case 'Last Week':
          startDate = now.subtract(Duration(days: 7));
          endDate = now;
          break;
        case 'This Month':
          startDate = DateTime(now.year, now.month, 1);
          endDate = now;
          break;
        case 'Last Month':
          startDate = DateTime(now.year, now.month - 1, 1);
          endDate = DateTime(now.year, now.month, 0);
          break;
        case 'This Year':
          startDate = DateTime(now.year, 1, 1);
          endDate = now;
          break;
        case 'Last Year':
          startDate = DateTime(now.year - 1, 1, 1);
          endDate = DateTime(now.year - 1, 12, 31);
          break;
        case 'Custom Date Range':
          startDate = filters.customDateRange!.start;
          endDate = filters.customDateRange!.end;
          break;
        default:
          startDate = DateTime(2000);
          endDate = DateTime(2101);
      }
      expenses = expenses.where((expense) => expense.date.isAfter(startDate) && expense.date.isBefore(endDate)).toList();
    }

    return expenses;
  }

  Color _getNextColor() {
    Color color = _availableColors[_colorIndex % _availableColors.length];
    _colorIndex++;
    return color;
  }

  void _clearFilters() {
    _fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: CustomAppBar(
          title: widget.isIncome ? 'Income List' : 'Expense List',
        ),
        drawer: CustomDrawer(),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTransactionPageWidget(isIncome: widget.isIncome),
                            ),
                          );
                        },
                        child: Text(widget.isIncome ? 'Add Income' : 'Add Expense'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final filters = await Navigator.push<FilterModel>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FilterPageWidget(),
                            ),
                          );
                          if (filters != null) {
                            _fetchExpenses(filters);
                          }
                        },
                        child: Text('Filters'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: activeFilters != null ? _clearFilters : null,
                        child: Text('Clear Filters'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeFilters != null ? Theme.of(context).primaryColor : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Expense>>(
                  future: _expensesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Failed to load expenses: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No expenses found.'));
                    } else {
                      final expenses = snapshot.data!;
                      return ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return Column(
                            children: [
                              _buildTransactionItem(
                                context,
                                expense.category,
                                DateFormat('yyyy-MM-dd').format(expense.date),
                                'Rs. ${expense.amount}',
                                expense.description,
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
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, String category, String date, String amount, String description) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
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
                      style: TextStyle(color: Color(0xFF0DA487)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
