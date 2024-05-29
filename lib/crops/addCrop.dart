import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../models/fields.dart';

const String baseUrl = 'http://farmapp.channab.com';

class AddCropPage extends StatefulWidget {
  @override
  _AddCropPageState createState() => _AddCropPageState();
}

class _AddCropPageState extends State<AddCropPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _varietyController = TextEditingController();
  TextEditingController _plantingDateController = TextEditingController();
  String? _selectedStage;
  int? _selectedField;
  bool _isUploading = false;
  late Future<List<Field>> _fieldsFuture;

  @override
  void initState() {
    super.initState();
    _plantingDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fieldsFuture = fetchFields();
  }

  Future<List<Field>> fetchFields() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/crops/api/fields/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> fieldsJson = json.decode(response.body);
      return fieldsJson.map((json) => Field.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load fields');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _plantingDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveCrop() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/crops/api/crops/create/'),
      );

      request.headers['Authorization'] = 'Token $token';
      request.fields['name'] = _nameController.text;
      request.fields['variety'] = _varietyController.text;
      request.fields['planting_date'] = _plantingDateController.text;
      request.fields['stage'] = _selectedStage!;
      request.fields['fields'] = _selectedField.toString();

      final response = await request.send();

      setState(() {
        _isUploading = false;
      });

      final responseBody = await response.stream.bytesToString();
      final responseJson = json.decode(responseBody);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        String errorMessage = responseJson['error'] ?? 'Failed to save crop';
        _showErrorDialog(errorMessage);
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
                  "Your crop has been created successfully.",
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
                    Navigator.of(context).pop(); // Go back to the previous screen
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
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
          'Add Crop',
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
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Crop Name',
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
                    return 'Please enter crop name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _varietyController,
                decoration: InputDecoration(
                  labelText: 'Variety',
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
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Planting Date',
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
                      Text(_plantingDateController.text,
                          style: TextStyle(color: Color(0xFF0DA487))),
                      Icon(Icons.calendar_today, color: Color(0xFF0DA487)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedStage,
                decoration: InputDecoration(
                  labelText: 'Stage',
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
                items: ['Planning', 'Planting', 'Harvesting'].map((String stage) {
                  return DropdownMenuItem<String>(
                    value: stage.toLowerCase(),
                    child: Text(stage, style: TextStyle(color: Color(0xFF0DA487))),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedStage = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a stage';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              FutureBuilder<List<Field>>(
                future: _fieldsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Failed to load fields');
                  } else {
                    final fields = snapshot.data!;
                    return DropdownButtonFormField<int>(
                      value: _selectedField,
                      decoration: InputDecoration(
                        labelText: 'Field',
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
                      items: fields.map((field) {
                        return DropdownMenuItem<int>(
                          value: field.id,
                          child: Text(field.name, style: TextStyle(color: Color(0xFF0DA487))),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedField = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a field';
                        }
                        return null;
                      },
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCrop,
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
