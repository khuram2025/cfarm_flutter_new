import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://farmapp.channab.com';

class EditEmployeePage extends StatefulWidget {
  final int employeeId;

  EditEmployeePage({required this.employeeId});

  @override
  _EditEmployeePageState createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _joiningDateController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  String _role = 'labour';
  File? _selectedFile;
  bool _isUploading = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeDetails();
  }

  Future<void> _fetchEmployeeDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    var response = await http.get(
      Uri.parse('$baseUrl/accounts/api/employee/${widget.employeeId}/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        _nameController.text = data['profile']['first_name'];
        _locationController.text = data['profile']['city'];
        _joiningDateController.text = data['profile']['joining_date'];
        _mobileController.text = data['mobile'];
        _endDateController.text = data['profile']['end_date'] ?? '';
        _role = data['role'];
        _isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateEmployee() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/accounts/api/edit_employee/${widget.employeeId}/'));

      request.headers['Authorization'] = 'Token $token';
      request.fields['mobile'] = _mobileController.text;
      request.fields['profile.first_name'] = _nameController.text;
      request.fields['profile.city'] = _locationController.text;
      request.fields['profile.joining_date'] = _joiningDateController.text;
      request.fields['profile.last_name'] = '';  // Providing default values
      request.fields['profile.email'] = '';  // Providing default values
      request.fields['profile.end_date'] = _endDateController.text;
      request.fields['role'] = _role;

      if (_selectedFile != null) {
        request.files.add(await http.MultipartFile.fromPath('profile.profile_picture', _selectedFile!.path));
      }

      var response = await request.send();

      setState(() {
        _isUploading = false;
      });

      final responseBody = await response.stream.bytesToString();
      final responseJson = json.decode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSuccessDialog();
      } else {
        String errorMessage = responseJson['error'] ?? 'Failed to update employee';
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
                  "Employee has been updated successfully.",
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

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Employee',
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
      body: _isLoading
          ? Center(
        child: SpinKitCircle(
          color: Color(0xFF0DA487),
          size: 50.0,
        ),
      )
          : _isUploading
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
              GestureDetector(
                onTap: _pickImage,
                child: _selectedFile == null
                    ? DottedBorder(
                  color: Colors.grey,
                  strokeWidth: 2,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    child: Center(
                      child: Text('Tap to select image'),
                    ),
                  ),
                )
                    : Image.file(_selectedFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Employee Name',
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
                    return 'Please enter employee name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
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
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () => _selectDate(context, _joiningDateController),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Joining Date',
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
                      Text(_joiningDateController.text, style: TextStyle(color: Color(0xFF0DA487))),
                      Icon(Icons.calendar_today, color: Color(0xFF0DA487)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () => _selectDate(context, _endDateController),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'End Date',
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
                      Text(_endDateController.text.isEmpty ? 'Select Date' : _endDateController.text,
                          style: TextStyle(color: Color(0xFF0DA487))),
                      Icon(Icons.calendar_today, color: Color(0xFF0DA487)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
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
                    return 'Please enter mobile number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(
                  labelText: 'Role',
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
                items: ['admin', 'read_only', 'labour'].map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role, style: TextStyle(color: Color(0xFF0DA487))),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _role = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateEmployee,
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
