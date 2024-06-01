import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/salary_component.dart';

class EditSalaryComponentScreen extends StatefulWidget {
  final SalaryComponent component;

  const EditSalaryComponentScreen({Key? key, required this.component}) : super(key: key);

  @override
  _EditSalaryComponentScreenState createState() => _EditSalaryComponentScreenState();
}

class _EditSalaryComponentScreenState extends State<EditSalaryComponentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late String _duration;
  final String baseUrl = "http://farmapp.channab.com";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.component.name);
    _amountController = TextEditingController(text: widget.component.amount.toString());
    _duration = widget.component.duration;
  }

  Future<void> _editSalaryComponent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (_formKey.currentState!.validate()) {
      final response = await http.put(
        Uri.parse('$baseUrl/accounts/api/salary_components/update/${widget.component.id}/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _nameController.text,
          'amount': _amountController.text,
          'duration': _duration,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Salary component updated successfully')));
        Navigator.pop(context, true); // Return true to indicate that the component was updated
      } else {
        print("Failed to update salary component: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update salary component')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Salary Component'),
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
                    _duration = newValue!;
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
                onPressed: _editSalaryComponent,
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
