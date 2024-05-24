import 'package:flutter/material.dart';

import '../Finance/transactionsScreen.dart';

// Define the IncomeExpenseWidget
class IncomeExpenseWidget extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final bool isIncome;
  final VoidCallback onTap;

  IncomeExpenseWidget({
    required this.title,
    required this.amount,
    required this.color,
    required this.isIncome,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: 120, // Adjust the width as needed
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(color: color, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Define the IncomeExpenseRow
class IncomeExpenseRow extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double todayMilk;

  IncomeExpenseRow({
    required this.totalIncome,
    required this.totalExpense,
    required this.todayMilk,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: IncomeExpenseWidget(
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
        ),
        SizedBox(width: 8),
        Expanded(
          child: IncomeExpenseWidget(
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
        ),
        SizedBox(width: 8),
        Expanded(
          child: IncomeExpenseWidget(
            title: 'Today Milk',
            amount: todayMilk,
            color: Colors.blue,
            isIncome: true, // Adjust this as needed
            onTap: () {
              // Define the action on tap if needed
            },
          ),
        ),
      ],
    );
  }
}
