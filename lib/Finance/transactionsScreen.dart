import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled3/Finance/addExpense.dart';
import '../home/finCustomeAppbar.dart';
import '../models/expense.dart';
import 'addTransaction.dart';
import 'transactionFilter.dart';
import '../home/customDrawer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionPageWidget extends StatefulWidget {
  final bool isIncome;

  const TransactionPageWidget({Key? key, required this.isIncome}) : super(key: key);

  @override
  State<TransactionPageWidget> createState() => _TransactionPageWidgetState();
}

class _TransactionPageWidgetState extends State<TransactionPageWidget> {
  late Future<List<Transaction>> _transactionsFuture;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  FilterModel? activeFilters = FilterModel(dateFilter: 'This Month', type: '', category: '', amountRange: RangeValues(0, 10000000), );
  Map<String, Color> _categoryColors = {};
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
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
    _fetchTransactions(activeFilters);
  }

  void _fetchTransactions([FilterModel? filters]) {
    setState(() {
      _transactionsFuture = fetchTransactions(filters);
      activeFilters = filters;
    });
  }

  Future<List<Transaction>> fetchTransactions([FilterModel? filters]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    final url = widget.isIncome
        ? 'http://farmapp.channab.com/erp/api/income/'
        : 'http://farmapp.channab.com/erp/api/expenses/';

    Map<String, String> queryParams = {};
    if (filters != null) {
      queryParams['time_filter'] = filters.dateFilter;
      if (filters.customDateRange != null) {
        queryParams['start_date'] = filters.customDateRange!.start.toIso8601String();
        queryParams['end_date'] = filters.customDateRange!.end.toIso8601String();
      }
      print('Applying Filters: ${filters.toJson()}');  // Debug statement
    }

    final uri = Uri.parse(url).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> transactionsJson = json.decode(response.body) as List;

      // Print the raw data received from the API
      print('Received Data: $transactionsJson');  // Debug statement

      List<Transaction> transactions = transactionsJson.map((json) => Transaction.fromJson(json)).toList();

      // Debug statement to check transactions after parsing JSON
      print('Parsed Transactions: $transactions');

      // Assign colors dynamically to categories
      transactions.forEach((transaction) {
        if (!_categoryColors.containsKey(transaction.category)) {
          _categoryColors[transaction.category] = _getNextColor();
        }
        if (!_categories.contains(transaction.category)) {
          _categories.add(transaction.category);
        }
      });

      return transactions;
    } else {
      print('Failed to load transactions with status code: ${response.statusCode}');
      throw Exception('Failed to load transactions with status code: ${response.statusCode}');
    }
  }

  List<Transaction> _applyFilters(List<Transaction> transactions, FilterModel filters) {
    if (filters.type != 'All') {
      transactions = transactions.where((transaction) => transaction.category == filters.type).toList();
    }
    if (filters.category != 'All') {
      transactions = transactions.where((transaction) => transaction.category == filters.category).toList();
    }
    transactions = transactions.where((transaction) => transaction.amount >= filters.amountRange.start && transaction.amount <= filters.amountRange.end).toList();

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
      print('Start Date: $startDate, End Date: $endDate');  // Debug statement
      transactions = transactions.where((transaction) => transaction.date.isAfter(startDate) && transaction.date.isBefore(endDate)).toList();
    }

    // Debug statement to check transactions after applying filters
    print('Filtered Transactions: $transactions');

    return transactions;
  }

  List<Transaction> _applyCategoryFilter(List<Transaction> transactions) {
    if (_selectedCategory != 'All') {
      transactions = transactions.where((transaction) => transaction.category == _selectedCategory).toList();
    }
    return transactions;
  }

  Color _getNextColor() {
    Color color = _availableColors[_colorIndex % _availableColors.length];
    _colorIndex++;
    return color;
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _fetchTransactions();
    });
  }

  void _handleDateChange(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _fetchTransactions();
    });
  }

  void _handleAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionEntryScreen(), // or AddTransactionScreen() for income
      ),
    );
  }

  void _handleFilter() async {
    final filters = await Navigator.push<FilterModel>(
      context,
      MaterialPageRoute(
        builder: (context) => FilterPageWidget(),
      ),
    );
    if (filters != null) {
      _fetchTransactions(filters);
    }
  }

  double _getTotalAmountForCategory(List<Transaction> transactions, String category) {
    double totalAmount = 0;
    transactions.forEach((transaction) {
      if (category == 'All' || transaction.category == category) {
        totalAmount += transaction.amount;
      }
    });
    return totalAmount;
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
        appBar: FinCustomAppBar(
          title: widget.isIncome ? 'Income' : 'Expense',
          isIncome: widget.isIncome,
          selectedDate: _selectedDate,
          onDateChanged: _handleDateChange,
          onAddTransaction: _handleAddTransaction,
          onFilter: _handleFilter,
        ),
        drawer: CustomDrawer(),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              FutureBuilder<List<Transaction>>(
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
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((category) {
                          double totalAmount = _getTotalAmountForCategory(transactions, category);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(
                                category == 'All'
                                    ? 'All (Rs. ${_getTotalAmountForCategory(transactions, 'All').toStringAsFixed(2)})'
                                    : '$category (Rs. ${totalAmount.toStringAsFixed(2)})',
                              ),
                              selected: _selectedCategory == category,
                              selectedColor: Color(0xFF0DA487).withOpacity(0.1),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: _selectedCategory == category ? Color(0xFF0DA487) : Colors.black,
                              ),
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedCategory = selected ? category : 'All';
                                  _fetchTransactions();
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
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
                      final transactions = _applyCategoryFilter(snapshot.data!);
                      return ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return Column(
                            children: [
                              _buildTransactionItem(
                                context,
                                transaction.category,
                                DateFormat('d MMM, yyyy').format(transaction.date),
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
