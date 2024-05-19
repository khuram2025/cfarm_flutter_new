import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String title;
  final bool isIncome;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final VoidCallback onAddTransaction;
  final VoidCallback onFilter;

  FinCustomAppBar({
    Key? key,
    required this.title,
    required this.isIncome,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onAddTransaction,
    required this.onFilter,
  })  : preferredSize = Size.fromHeight(56.0),
        super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu, color: Color(0xFF0DA487)),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: GestureDetector(
        onTap: () => _selectDate(context),
        child: Row(
          children: [
            Text(
              "${DateFormat('MMMM yyyy').format(selectedDate)} ${isIncome ? 'Income' : 'Expense'}",
              style: TextStyle(
                fontWeight: FontWeight.w400, // Reduced font weight
                color: Color(0xFF0DA487),
                fontSize: 18// Set title color
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Color(0xFF0DA487)), // Set icon color
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add, color: Color(0xFF0DA487)), // Set icon color
          onPressed: onAddTransaction,
        ),
        IconButton(
          icon: Icon(Icons.filter_list, color: Color(0xFF0DA487)), // Set icon color
          onPressed: onFilter,
        ),
      ],
    );
  }
}
