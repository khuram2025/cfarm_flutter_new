import 'package:flutter/material.dart';
import 'Finance/addExpense.dart';
import 'Finance/amountentry.dart';
import 'Finance/confirmation.dart';
import 'Finance/finDashbaordScreen.dart';
import 'Finance/incomeScreen.dart';
import 'Finance/transactionFilter.dart';
import 'Finance/transactionList.dart';
import 'Finance/transactionsScreen.dart';
import 'accounts/login.dart';
import 'Finance/addTransaction.dart'; // Import AddTransactionPageWidget
import 'dairy/AnimalListPage.dart';
import 'home/homePage.dart';                   // Import HomePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPageWidget(),
      routes: {
        '/login': (context) => LoginPageWidget(),
        '/home': (context) => HomePage(),
        '/add-transaction': (context) => AddTransactionPageWidget(isIncome: false),
        '/transactions': (context) => TransactionPageWidget(isIncome: false),
        '/filter': (context) => FilterPageWidget(),
        '/animals': (context) => AnimalListMobilePage(),

        '/success': (context) => SuccessScreen(),
        '/erp': (context) => TransactionEntryScreen(),
        '/findashboard': (context) => AnalyticsScreen(),



        // '/income': (context) => IncomeScreen(),
      },
    );
  }
}
