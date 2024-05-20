import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddSalaryTransactionScreen extends StatefulWidget {
  @override
  _AddSalaryTransactionScreenState createState() => _AddSalaryTransactionScreenState();
}

class _AddSalaryTransactionScreenState extends State<AddSalaryTransactionScreen> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  String? _selectedEmployee;
  String? _selectedComponent;
  late Future<List<String>> _employeesFuture;
  late Future<List<String>> _componentsFuture;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _employeesFuture = fetchEmployees();
    _componentsFuture = fetchSalaryComponents();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _createSalaryTransaction() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (_selectedEmployee != null && _selectedComponent != null && _amountController.text.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://192.168.8.153/accounts/api/salary-transactions/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'farm_member': _selectedEmployee,
          'component': _selectedComponent,
          'amount_paid': _amountController.text,
          'transaction_date': DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_dateController.text)),
          'description': _noteController.text,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create salary transaction')));
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            height: 330,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF0DA487), size: 100),
                SizedBox(height: 20),
                Text(
                  "Success",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Your salary transaction has been created successfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/transactions');
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0DA487),
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<String>> fetchEmployees() async {
    // Fetch the list of active employees from the API
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final response = await http.get(
      Uri.parse('http://192.168.8.153/accounts/api/active-employees/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => e['name'] as String).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  Future<List<String>> fetchSalaryComponents() async {
    // Fetch the list of salary components from the API
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final response = await http.get(
      Uri.parse('http://192.168.8.153/accounts/api/salary-components/<int:member_id>/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => e['name'] as String).toList();
    } else {
      throw Exception('Failed to load salary components');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Salary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0DA487),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<String>>(
                future: _employeesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Failed to load employees');
                  } else {
                    final employees = snapshot.data!;
                    return DropdownButtonFormField(
                      value: _selectedEmployee,
                      decoration: InputDecoration(
                        labelText: 'Select Employee',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0DA487)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0DA487)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0DA487)),
                        ),
                        labelStyle: TextStyle(color: Color(0xFF0DA487)),
                      ),
                      items: employees.map((String employee) {
                        return DropdownMenuItem(
                          value: employee,
                          child: Text(employee, style: TextStyle(color: Color(0xFF0DA487))),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedEmployee = newValue as String?;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an employee';
                        }
                        return null;
                      },
                    );
                  }
                },
              ),
              SizedBox(height: 10),
              FutureBuilder<List<String>>(
                future: _componentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Failed to load salary components');
                  } else {
                    final components = snapshot.data!;
                    return DropdownButtonFormField(
                      value: _selectedComponent,
                      decoration: InputDecoration(
                        labelText: 'Select Component',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0DA487)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0DA487)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0DA487)),
                        ),
                        labelStyle: TextStyle(color: Color(0xFF0DA487)),
                      ),
                      items: components.map((String component) {
                        return DropdownMenuItem(
                          value: component,
                          child: Text(component, style: TextStyle(color: Color(0xFF0DA487))),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedComponent = newValue as String?;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a component';
                        }
                        return null;
                      },
                    );
                  }
                },
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0DA487)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0DA487)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0DA487)),
                    ),
                    labelStyle: TextStyle(color: Color(0xFF0DA487)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_dateController.text, style: TextStyle(color: Color(0xFF0DA487))),
                      Icon(Icons.calendar_today, color: Color(0xFF0DA487)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Salary',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0DA487)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0DA487)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0DA487)),
                  ),
                  labelStyle: TextStyle(color: Color(0xFF0DA487)),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: Color(0xFF0DA487)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0DA487)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0DA487)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF0DA487)),
                  ),
                  labelStyle: TextStyle(color: Color(0xFF0DA487)),
                ),
                maxLines: 3,
                style: TextStyle(color: Color(0xFF0DA487)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createSalaryTransaction,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0DA487),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
