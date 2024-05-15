import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'CHANNAB',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            decoration: BoxDecoration(
              color: Color(0xFF0DA487),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.pets),
            title: Text('Animals'),
            onTap: () {
              Navigator.pushNamed(context, '/animals');
            },
          ),
          ListTile(
            leading: Icon(Icons.money),
            title: Text('Expense'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/transactions', arguments: false);
            },
          ),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Text('Income'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/transactions', arguments: true);
            },
          ),
          ListTile(
            leading: Icon(Icons.local_drink),
            title: Text('Milk Records'),
            onTap: () {
              Navigator.pushNamed(context, '/milk-records');
            },
          ),
        ],
      ),
    );
  }
}