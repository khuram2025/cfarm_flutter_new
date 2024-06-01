class SalaryTransaction {
  final int id;
  final String componentName;
  final double amountPaid;
  final String transactionDate;
  final String? description;

  SalaryTransaction({
    required this.id,
    required this.componentName,
    required this.amountPaid,
    required this.transactionDate,
    this.description,
  });

  factory SalaryTransaction.fromJson(Map<String, dynamic> json) {
    return SalaryTransaction(
      id: json['id'],
      componentName: json['component_name'] ?? '',
      amountPaid: double.parse(json['amount_paid'].toString()),
      transactionDate: json['transaction_date'],
      description: json['description'],
    );
  }
}
