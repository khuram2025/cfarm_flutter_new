import 'package:flutter/material.dart';

class EmployeeInfoTable extends StatelessWidget {
  final String name;
  final String mobileNumber;
  final String email;
  final String role;
  final String joiningDate;
  final String endDate;
  final String status;
  final String monthlySalary;
  final String totalSalaryReceived;
  final String expectedSalaryTillNow;
  final String remainingSalary;
  final String totalMonthlySalary;

  const EmployeeInfoTable({
    Key? key,
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.role,
    required this.joiningDate,
    required this.endDate,
    required this.status,
    required this.monthlySalary,
    required this.totalSalaryReceived,
    required this.expectedSalaryTillNow,
    required this.remainingSalary,
    required this.totalMonthlySalary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Table(
        columnWidths: {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        children: [
          _buildTableRow('Name', _capitalize(name)),
          _buildTableRow('Mobile Number', mobileNumber),
          _buildTableRow('Email', email),
          _buildTableRow('Role', _capitalize(role)),
          _buildTableRow('Joining Date', joiningDate),
          _buildTableRow('End Date', endDate),
          _buildTableRow('Status', _capitalize(status)),
          _buildTableRow('Monthly Salary', totalMonthlySalary),
          _buildTableRow('Salary Received', totalSalaryReceived),
          _buildTableRow('Salary Till Now', expectedSalaryTillNow),
          _buildTableRow('Remaining Salary', remainingSalary, isRemainingSalary: true),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value, {bool isRemainingSalary = false}) {
    Color textColor;
    if (isRemainingSalary) {
      double remainingSalaryValue = double.tryParse(value) ?? 0.0;
      textColor = remainingSalaryValue >= 0 ? Colors.green : Colors.red;
    } else {
      textColor = Colors.black;
    }

    return TableRow(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          color: Colors.grey.shade200,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}
