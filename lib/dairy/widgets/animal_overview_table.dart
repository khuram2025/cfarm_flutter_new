import 'package:flutter/material.dart';

class AnimalOverviewTable extends StatelessWidget {
  final String tag;
  final String age;
  final String type;
  final String status;
  final String gender;
  final String price;

  const AnimalOverviewTable({
    Key? key,
    required this.tag,
    required this.age,
    required this.type,
    required this.status,
    required this.gender,
    required this.price,
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
          _buildTableRow('Tag', _capitalize(tag)),
          _buildTableRow('Age', age),
          _buildTableRow('Type', _capitalize(type)),
          _buildTableRow('Status', _capitalize(status)),
          _buildTableRow('Gender', _capitalize(gender)),
          _buildTableRow('Price', price),
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
