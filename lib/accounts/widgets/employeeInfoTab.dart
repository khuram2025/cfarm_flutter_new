import 'package:flutter/material.dart';

class EmployeeInfoTable extends StatelessWidget {
  final String name;
  final String mobileNumber;
  final String email;
  final String role;
  final String joiningDate;
  final String endDate;
  final String status;

  const EmployeeInfoTable({
    Key? key,
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.role,
    required this.joiningDate,
    required this.endDate,
    required this.status,
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
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          color: Colors.grey.shade200,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
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
