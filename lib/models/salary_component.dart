import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/salary_component.dart';

class SalaryTabPage extends StatefulWidget {
  final int employeeId;

  const SalaryTabPage({Key? key, required this.employeeId}) : super(key: key);

  @override
  _SalaryTabPageState createState() => _SalaryTabPageState();
}

class _SalaryTabPageState extends State<SalaryTabPage> {
  List<SalaryComponent> salaryComponents = [];

  @override
  void initState() {
    super.initState();
    fetchSalaryDetails();
  }

  final String baseUrl = "http://farmapp.channab.com";

  Future<void> fetchSalaryDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/accounts/api/employees/${widget.employeeId}/salary_components/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      final componentsJson = json.decode(response.body);

      print('Received Salary Components: $componentsJson'); // Print salary components data

      setState(() {
        salaryComponents = (componentsJson as List)
            .map((data) => SalaryComponent.fromJson(data))
            .toList();
      });
    } else {
      print('Failed to load salary details');
      print('Response: ${response.body}');
    }
  }

  void deleteComponent(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.delete(
      Uri.parse('$baseUrl/accounts/api/salary_components/$id/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        salaryComponents.removeWhere((component) => component.id == id);
      });
    } else {
      print('Failed to delete salary component');
    }
  }

  void editComponent(SalaryComponent component) {
    // Navigate to edit page or show a dialog to edit the component
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: salaryComponents.length,
            itemBuilder: (context, index) {
              final component = salaryComponents[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text('${component.name} (${component.duration})'),
                  subtitle: Text('Amount: ${component.amount}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => editComponent(component),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteComponent(component.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SalaryComponent {
  final int id;
  final String name;
  final double amount;
  final String duration;

  SalaryComponent({
    required this.id,
    required this.name,
    required this.amount,
    required this.duration,
  });

  factory SalaryComponent.fromJson(Map<String, dynamic> json) {
    return SalaryComponent(
      id: json['id'],
      name: json['name'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      duration: json['duration'],
    );
  }
}
