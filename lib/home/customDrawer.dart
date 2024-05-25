import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:untitled3/Finance/transactionsScreen.dart';

class CustomDrawer extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    final response = await http.post(
      Uri.parse('https://farm.channab.com/accounts/api/logout/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );
    if (response.statusCode == 200) {
      prefs.remove('auth_token');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      // Handle logout error
    }
  }

  Future<Map<String, String>> _fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    final response = await http.get(
      Uri.parse('https://farm.channab.com/accounts/api/user-profile/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      String firstName = data['first_name'];
      String lastName = data['last_name'];
      return {'firstName': firstName, 'lastName': lastName};
    } else {
      return {'firstName': '', 'lastName': ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, String>>(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading profile'));
          } else {
            String firstName = snapshot.data!['firstName']!;
            String lastName = snapshot.data!['lastName']!;
            String initials = (firstName.isNotEmpty ? firstName[0] : '') + (lastName.isNotEmpty ? lastName[0] : '');

            return ListView(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text('$firstName $lastName'),
                  accountEmail: null,
                  currentAccountPicture: CircleAvatar(
                    child: Text(
                      initials,
                      style: TextStyle(fontSize: 40.0),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionPageWidget(isIncome: false),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text('Income'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionPageWidget(isIncome: true),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.local_drink),
                  title: Text('Milk Records'),
                  onTap: () {
                    Navigator.pushNamed(context, '/milk-records');
                  },
                ),

                ListTile(
                  leading: Icon(Icons.local_drink),
                  title: Text('findashboard'),
                  onTap: () {
                    Navigator.pushNamed(context, '/findashboard');
                  },
                ),



                Spacer(),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () => _logout(context),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
