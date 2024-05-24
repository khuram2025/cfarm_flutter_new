import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/animalCategoryInfo.dart';
import '../widgets/animal_bar_chart_widget.dart';
import '../widgets/income_expense_widget.dart';
import 'customDrawer.dart';
import '../widgets/chart_widget.dart';
import '../widgets/transaction_list_widget.dart';
import '../models/erpModels.dart';
import '../apis/erpApiServices.dart';
import 'customeAppBar.dart';
import '../services/animalsAPI.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primaryColor = Color(0xFF0DA487);
  late Future<List<SummaryData>> _summaryDataFuture;
  late Future<List<Transaction>> _transactionsFuture;

  double totalIncome = 0;
  double totalExpense = 0;
  double todayMilk = 105; // Example value, replace with actual logic to fetch this data.

  List<Map<String, dynamic>> _typesWithCounts = [];
  List<Map<String, dynamic>> _categoriesWithCounts = [];

  final List<Color> _colors = [
    Color(0xFF0DA487),
    Color(0xFFE91E63),
    Color(0xFFFF9800),
    Color(0xFF9E9E9E),
    Color(0xFF2196F3),
    Color(0xFF673AB7),
  ];

  @override
  void initState() {
    super.initState();
    _fetchSummaryData();
    _fetchTransactions();
    _fetchCategoriesAndTypes();
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

  void _fetchCategoriesAndTypes() async {
    try {
      var data = await AnimalsAPI().fetchCategoriesAndTypes();
      setState(() {
        _typesWithCounts = data['types'].map<Map<String, dynamic>>((t) => {'animal_type': t['animal_type'], 'count': t['count']}).toList();
        _categoriesWithCounts = data['categories'].map<Map<String, dynamic>>((c) => {'category': c['category__title'], 'count': c['count']}).toList();
      });
    } catch (e) {
      print('Failed to load categories and types');
    }
  }

  Map<String, Color> _assignColorsToCategories(List<Map<String, dynamic>> categories) {
    Map<String, Color> categoryColorMap = {};
    for (int i = 0; i < categories.length; i++) {
      categoryColorMap[categories[i]['category']] = _colors[i % _colors.length];
    }
    return categoryColorMap;
  }

  @override
  Widget build(BuildContext context) {
    final categoryColorMap = _assignColorsToCategories(_categoriesWithCounts);

    return Scaffold(
      appBar: CustomAppBar(title: 'Channab',),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IncomeExpenseRow(
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                todayMilk: todayMilk,
              ),
              SizedBox(height: 16), // Add some spacing between the widgets
              TransactionListWidget(transactionsFuture: _transactionsFuture),
              SizedBox(height: 16), // Add some spacing between the widgets
              ChartWidget(summaryDataFuture: _summaryDataFuture),

              AnimalCategoryInfo(
                categories: _categoriesWithCounts,
                categoryColorMap: categoryColorMap,
              ),
              AnimalBarChartWidget(
                animalTypes: _typesWithCounts,
                animalCategories: _categoriesWithCounts,
              ),
              SizedBox(height: 16), // Add some spacing between the widgets

              // Add more widgets here if needed
            ],
          ),
        ),
      ),
      // bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
