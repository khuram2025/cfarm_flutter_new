class SummaryData {
  SummaryData({required this.month, required this.totalIncome, required this.totalExpense});

  final String month;
  final double totalIncome;
  final double totalExpense;

  factory SummaryData.fromJson(Map<String, dynamic> json) {
    return SummaryData(
      month: json['month'] ?? '',
      totalIncome: double.tryParse(json['total_income'].toString()) ?? 0.0,
      totalExpense: double.tryParse(json['total_expense'].toString()) ?? 0.0,
    );
  }
}

class Transaction {
  final String category;
  final double amount;
  final DateTime date;
  final bool isIncome;

  Transaction({
    required this.category,
    required this.amount,
    required this.date,
    required this.isIncome,
  });

  factory Transaction.fromJson(Map<String, dynamic> json, bool isIncome) {
    return Transaction(
      category: json['category__name'] ?? '',
      amount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.now(), // Date is not available in the current API response
      isIncome: isIncome,
    );
  }
}



