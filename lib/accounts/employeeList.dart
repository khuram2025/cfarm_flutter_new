import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../home/customDrawer.dart';
import '../home/finCustomeAppbar.dart';
import '../models/employees.dart';
import 'addEmployee.dart';
import 'employeeDetail.dart';

const String baseUrl = 'http://farmapp.channab.com';

class EmployeeListPage extends StatefulWidget {
  @override
  _EmployeeListPageState createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  List<Employee> employees = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/accounts/api/active_employees/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> employeesJson = json.decode(response.body);
      List<Employee> tempEmployees = employeesJson.map((json) {
        try {
          return Employee.fromJson(json);
        } catch (e) {
          print('Error parsing employee: $e');
          return null;
        }
      }).where((employee) => employee != null).toList().cast<Employee>();

      setState(() {
        employees = tempEmployees;
      });
    } else {
      print('Failed to load employees with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinCustomAppBar(
        title: 'Employees List',
        onAddTransaction: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEmployeePage(),
            ),
          );
        }, onFilter: () {  },

      ),
      drawer: CustomDrawer(),
      body: employees.isEmpty
          ? Center(child: Text('No employees available'))
          : ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return EmployeeCard(
            employee: employee,
            onEmployeeUpdated: fetchEmployees, // Pass the callback to refresh the list
          );
        },
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onEmployeeUpdated; // Callback to refresh the list

  const EmployeeCard({Key? key, required this.employee, required this.onEmployeeUpdated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDetailPage(employee: employee),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: SizedBox(
          height: 150,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: employee.imageUrl != null
                      ? Image.network(
                    employee.imageUrl!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey,
                    child: Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${employee.firstName} ${employee.lastName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF0DA487),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddEmployeePage(),
                                    ),
                                  ).then((_) {
                                    onEmployeeUpdated(); // Refresh the employee list after returning from AddEmployeePage
                                  });
                                },
                                iconSize: 14,
                                color: Color(0xFF0DA487),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever_rounded),
                                onPressed: () {
                                  // Handle delete action for this employee
                                },
                                iconSize: 16,
                                color: Colors.red,
                                padding: EdgeInsets.zero, // Remove any padding
                                constraints: BoxConstraints(), // Remove default constraints
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mobile: ${employee.mobile}',
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Email: ${employee.email}',
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Joining Date: ${employee.joiningDate}',
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MediumButton(
                            btnText: '${employee.status?.capitalize()}',
                            onPressed: () {
                              // Handle action for Status button
                            },
                          ),
                          SizedBox(width: 8),
                          MediumButton(
                            btnText: '${employee.role?.capitalize()}',
                            onPressed: () {
                              // Handle action for Role button
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MediumButton extends StatelessWidget {
  final String btnText;
  final VoidCallback onPressed;

  const MediumButton({required this.btnText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Color(0xFF0DA487)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        btnText,
        style: TextStyle(
          color: Color(0xFF0DA487),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this == null) {
      return this;
    }
    return '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}';
  }
}
