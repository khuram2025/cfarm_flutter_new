class SalaryTransaction {
  final int id;
  final int farmMemberId;
  final int componentId;
  final String componentName;
  final double amountPaid;
  final String transactionDate;
  final String? description;

  SalaryTransaction({
    required this.id,
    required this.farmMemberId,
    required this.componentId,
    required this.componentName,
    required this.amountPaid,
    required this.transactionDate,
    this.description,
  });

  factory SalaryTransaction.fromJson(Map<String, dynamic> json) {
    return SalaryTransaction(
      id: json['id'],
      farmMemberId: json['farm_member'],
      componentId: json['component'],
      componentName: json['component_name'] ?? '',
      amountPaid: double.parse(json['amount_paid'].toString()),
      transactionDate: json['transaction_date'],
      description: json['description'],
    );
  }
}
