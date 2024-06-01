class SalaryTransaction {
  final int id;
  final String component; // Changed to String to hold the component's name
  final double amount_paid;
  final String transaction_date;

  SalaryTransaction({
    required this.id,
    required this.component,
    required this.amount_paid,
    required this.transaction_date,
  });

  factory SalaryTransaction.fromJson(Map<String, dynamic> json) {
    return SalaryTransaction(
      id: json['id'],
      component: json['component'], // Assuming this is the name of the component
      amount_paid: json['amount_paid'].toDouble(),
      transaction_date: json['transaction_date'],
    );
  }
}
