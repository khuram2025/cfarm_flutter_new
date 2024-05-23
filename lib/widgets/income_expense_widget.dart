import 'package:flutter/material.dart';

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
