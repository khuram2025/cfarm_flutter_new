import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnimalWeightTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const AnimalWeightTable({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        columnWidths: {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(2),
          4: FlexColumnWidth(1),
        },
        border: TableBorder(
          horizontalInside: BorderSide(
            width: 1,
            color: Colors.grey.shade300,
          ),
        ),
        children: [
          _buildTableHeader(),
          ...data.map((row) => _buildTableRow(row)).toList(),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        _buildHeaderCell('Date'),
        _buildHeaderCell('Weight (kg)'),
        _buildHeaderCell('Weight Gain (kg)'),
        _buildHeaderCell('Notes'),
        _buildHeaderCell('Action'),
      ],
    );
  }

  Widget _buildHeaderCell(String label) {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Color(0xFF0DA487),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> row) {
    return TableRow(
      children: [
        _buildTableCell(row['date']),
        _buildTableCell(row['weight'].toString()),
        _buildTableCell(row['weightGain'].toString()),
        _buildTableCell(row['notes']),
        _buildActionCell(),
      ],
    );
  }

  Widget _buildTableCell(String value) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildActionCell() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.edit),
            color: Color(0xFF0DA487),
            onPressed: () {
              // Handle edit action
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_forever_rounded),
            color: Colors.red,
            onPressed: () {
              // Handle delete action
            },
          ),
        ],
      ),
    );
  }
}
