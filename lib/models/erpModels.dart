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
  Transaction({required this.category, required this.amount, required this.date});

  final String category;
  final double amount;
  final DateTime date;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      category: json['category'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: DateTime.parse(json['date']),
    );
  }
}
