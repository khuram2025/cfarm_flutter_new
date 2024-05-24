import 'package:flutter/material.dart';
import '../models/erpModels.dart';

class TransactionListWidget extends StatelessWidget {
  final Future<List<Transaction>> transactionsFuture;

  TransactionListWidget({required this.transactionsFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transaction>>(
      future: transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load transactions: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No transactions found.'));
        } else {
          final transactions = snapshot.data!;
          final categories = _getCategoryTotals(transactions);
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Column(
                children: [
                  _buildCategoryItem(
                    context,
                    category['category']!,
                    'Rs. ${category['total']}',
                    category['isIncome'] == 'true',
                  ),
                  Divider(thickness: .5, color: Colors.grey[200]),
                ],
              );
            },
          );
        }
      },
    );
  }

  List<Map<String, String>> _getCategoryTotals(List<Transaction> transactions) {
    Map<String, double> categoryTotals = {};
    Map<String, bool> categoryTypes = {};

    for (var transaction in transactions) {
      if (!categoryTotals.containsKey(transaction.category)) {
        categoryTotals[transaction.category] = 0;
        categoryTypes[transaction.category] = transaction.isIncome;
      }
      categoryTotals[transaction.category] = categoryTotals[transaction.category]! + transaction.amount;
    }

    return categoryTotals.entries
        .map((entry) => {
      'category': entry.key,
      'total': entry.value.toString(),
      'isIncome': categoryTypes[entry.key].toString(),
    })
        .toList();
  }

  Widget _buildCategoryItem(BuildContext context, String category, String total, bool isIncome) {
    Color categoryColor = isIncome ? Color(0xFF0DA487) : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              category,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: categoryColor),
            ),
          ),
          Text(
            total,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: categoryColor),
          ),
        ],
      ),
    );
  }
}
