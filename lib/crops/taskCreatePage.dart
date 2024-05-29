import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://192.168.8.153';

class CreateTaskPage extends StatefulWidget {
  final int cropId;

  const CreateTaskPage({Key? key, required this.cropId}) : super(key: key);

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String _recurrence = 'single';
  int _recurrenceCount = 1;
  DateTime _startDate = DateTime.now().add(Duration(days: 1));
  bool _isUploading = false;

  Future<void> _createTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      final response = await http.post(
        Uri.parse('$baseUrl/crops/api/tasks/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
        body: json.encode({
          'crop': widget.cropId,
          'title': _titleController.text,
          'description': _descriptionController.text,
          'recurrence': _recurrence,
          'recurrence_count': _recurrenceCount,
          'start_date': _startDate.toIso8601String().split('T')[0], // Ensure correct format
        }),
      );

      setState(() {
        _isUploading = false;
      });

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        final responseJson = json.decode(response.body);
        print('Response body: $responseJson');
        String errorMessage = responseJson['error'] ?? 'Failed to create task';
        _showErrorDialog(errorMessage);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Task',
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
      body: _isUploading
          ? Center(
        child: SpinKitCircle(
          color: Color(0xFF0DA487),
          size: 50.0,
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
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
                style: TextStyle(color: Color(0xFF0DA487)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
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
                style: TextStyle(color: Color(0xFF0DA487)),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField(
                value: _recurrence,
                items: [
                  DropdownMenuItem(value: 'single', child: Text('Single')),
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _recurrence = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Recurrence',
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
                style: TextStyle(color: Color(0xFF0DA487)),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Recurrence Count',
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
                onSaved: (value) {
                  _recurrenceCount = int.parse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter recurrence count';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text('${_startDate.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != _startDate)
                    setState(() {
                      _startDate = pickedDate;
                    });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createTask,
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
