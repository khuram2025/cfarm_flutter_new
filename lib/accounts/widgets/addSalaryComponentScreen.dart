import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddSalaryComponentScreen extends StatefulWidget {
  final int employeeId;

  const AddSalaryComponentScreen({Key? key, required this.employeeId}) : super(key: key);

  @override
  _AddSalaryComponentScreenState createState() => _AddSalaryComponentScreenState();
}

class _AddSalaryComponentScreenState extends State<AddSalaryComponentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _duration;
  final String baseUrl = "http://farmapp.channab.com";

  Future<void> _createSalaryComponent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('$baseUrl/api/salary_components/create/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'employee_id': widget.employeeId,
          'name': _nameController.text,
          'amount': _amountController.text,
          'duration': _duration,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Salary component created successfully')));
        Navigator.pop(context);
      } else {
        print("Failed to create salary component: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create salary component')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Salary Component'),
        backgroundColor: Color(0xFF0DA487),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _duration,
                decoration: InputDecoration(
                  labelText: 'Duration',
                  border: OutlineInputBorder(),
                ),
                items: ['daily', 'monthly', 'yearly'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _duration = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a duration';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createSalaryComponent,
                child: Text('Save'),
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
