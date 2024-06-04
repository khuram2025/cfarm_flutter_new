import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://farmapp.channab.com';

class NoteCreatePage extends StatefulWidget {
  final int cropId;

  const NoteCreatePage({Key? key, required this.cropId}) : super(key: key);

  @override
  _NoteCreatePageState createState() => _NoteCreatePageState();
}

class _NoteCreatePageState extends State<NoteCreatePage> {
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submitNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('$baseUrl/crops/api/crop-notes/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        'crop': widget.cropId,
        'description': _descriptionController.text,
        'creation_date': _selectedDate.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, true); // Indicate that the note was created
    } else {
      print('Failed to create note with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0DA487),
        title: Text('Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text(
                    'Date: ',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _selectedDate)
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                    },
                    child: Text(
                      "${_selectedDate.toLocal()}".split(' ')[0],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0DA487),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0DA487),
                ),
                onPressed: _submitNote,
                child: Text('Save Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
