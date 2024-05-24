import 'package:flutter/material.dart';

class FinCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String title;
  final VoidCallback onAddTransaction;
  final VoidCallback onFilter;

  FinCustomAppBar({
    Key? key,
    required this.title,
    required this.onAddTransaction,
    required this.onFilter,
  })  : preferredSize = Size.fromHeight(56.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu, color: Color(0xFF0DA487)),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w400, // Reduced font weight
          color: Color(0xFF0DA487),
          fontSize: 18, // Set title color
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
