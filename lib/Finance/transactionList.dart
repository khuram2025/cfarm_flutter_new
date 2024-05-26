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

void main() {
  runApp(MaterialApp(
    home: TransactionListScreen(isIncome: false),
  ));
}

class TransactionListScreen extends StatefulWidget {
  final bool isIncome;

  const TransactionListScreen({Key? key, required this.isIncome}) : super(key: key);

  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late Future<List<Expense>> _expensesFuture;
  FilterModel? activeFilters;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  void _fetchTransactions([FilterModel? filters]) {
    setState(() {
      _expensesFuture = fetchExpenses(filters);
      activeFilters = filters;
    });
  }

  Future<List<Expense>> fetchExpenses([FilterModel? filters]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String apiUrl = widget.isIncome
        ? 'http://34.207.117.85:8001/erp/api/income/'
        : 'http://34.207.117.85:8001/erp/api/expenses/';

    final response = await http.get(
      Uri.parse(apiUrl),
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

      return expenses;
    } else {
      print('Failed to load transactions with status code: ${response.statusCode}');
      throw Exception('Failed to load transactions with status code: ${response.statusCode}');
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

  void _clearFilters() {
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                            _fetchTransactions(filters);
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
                              const Divider(),
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

  Widget _buildTransactionItem(BuildContext context, String category, String date, String amount, String? description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Text(
                date,
                style: Theme.of(context).textTheme.caption,
              ),
              if (description != null) Text(description),
            ],
          ),
          Row(
            children: [
              Icon(
                widget.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: widget.isIncome ? Color(0xFF0DA487) : Color(0xFFEE8B60),
                size: 24,
              ),
              Text(
                amount,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.isIncome ? Color(0xFF0DA487) : Color(0xFFEE8B60),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.delete_sharp,
                color: Theme.of(context).errorColor,
                size: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
    return Expense(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: double.parse(json['amount']),
      category: json['category'],
      description: json['description'] ?? '',
    );
  }
}
