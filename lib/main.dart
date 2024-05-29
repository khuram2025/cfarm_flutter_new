import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Finance/confirmation.dart';
import 'Finance/finDashbaordScreen.dart';
import 'Finance/transactionFilter.dart';
import 'Finance/transactionsScreen.dart';
import 'accounts/login.dart';
import 'Finance/addTransaction.dart';

import 'crops/feildsList.dart';
import 'dairy/AnimalListPage.dart';
import 'home/homePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await checkLoginStatus();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');
  if (token != null) {
    // Optionally, you can verify the token with your backend here.
    return true;
  }
  return false;
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLoggedIn ? HomePage() : LoginPageWidget(),
      routes: {
        '/login': (context) => LoginPageWidget(),
        '/home': (context) => HomePage(),
        '/add-transaction': (context) => AddTransactionPageWidget(isIncome: false),
        '/transactions': (context) => TransactionPageWidget(isIncome: false),
        '/filter': (context) => FilterPageWidget(),
        '/animals': (context) => AnimalListMobilePage(),
        '/success': (context) => SuccessScreen(),
        '/findashboard': (context) => AnalyticsScreen(),
        '/feilds': (context) => FieldListPage(),

      },
    );
  }
}
