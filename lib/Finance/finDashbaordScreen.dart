import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled3/Finance/transactionsScreen.dart';

import '../apis/erpApiServices.dart';
import '../models/erpModels.dart';
import '../widgets/animalCategoryWidgets.dart';
import '../widgets/chart_widget.dart';
import '../widgets/income_expense_widget.dart';
import '../widgets/transaction_list_widget.dart';

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

  double totalIncome = 0;
  double totalExpense = 0;
  double todayMilk = 105; // Example value, replace with actual logic to fetch this data.

  Map<String, int> animalCounts = {
    'All': 27,  // Total of all animals
    'Milking': 10,  // Example values, replace with actual data fetching logic
    'Pregnant': 5,
    'Dry': 7,
    'Breeder': 3,
    'Other': 2,
  };

  @override
  void initState() {
    super.initState();
    _fetchSummaryData();
    _fetchTransactions();
  }

  void _fetchSummaryData() {
    setState(() {
      _summaryDataFuture = ApiService.fetchSummaryData();
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
      _transactionsFuture = ApiService.fetchTransactions();
    });
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
                IncomeExpenseWidget(
                  title: 'Income',
                  amount: totalIncome,
                  color: Colors.green,
                  isIncome: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionPageWidget(isIncome: true),
                      ),
                    );
                  },
                ),
                SizedBox(width: 8),
                IncomeExpenseWidget(
                  title: 'Expenses',
                  amount: totalExpense,
                  color: Colors.red,
                  isIncome: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionPageWidget(isIncome: false),
                      ),
                    );
                  },
                ),
                SizedBox(width: 16),
                IncomeExpenseWidget(
                  title: 'Today Milk',
                  amount: todayMilk,
                  color: Colors.blue,
                  isIncome: true, // Adjust this as needed
                  onTap: () {
                    // Define the action on tap if needed
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            ChartWidget(summaryDataFuture: _summaryDataFuture),
            SizedBox(height: 16),
            TransactionListWidget(transactionsFuture: _transactionsFuture),

            Text("Animal Types"),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: animalCounts.keys.map((category) {
                  Color color;
                  switch (category) {
                    case 'Milking':
                      color = Colors.green;
                      break;
                    case 'Pregnant':
                      color = Colors.pink;
                      break;
                    case 'Dry':
                      color = Colors.brown;
                      break;
                    case 'Breeder':
                      color = Colors.orange;
                      break;
                    case 'Other':
                      color = Colors.grey;
                      break;
                    default:
                      color = Colors.blue;
                  }
                  return AnimalCategoryWidget(
                    title: category,
                    count: animalCounts[category]!,
                    color: color,
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
