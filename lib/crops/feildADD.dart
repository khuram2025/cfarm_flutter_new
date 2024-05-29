import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const String baseUrl = 'http://farmapp.channab.com';

class AddFieldPage extends StatefulWidget {
  final int? fieldId;  // Field ID for editing, null for creating

  const AddFieldPage({Key? key, this.fieldId}) : super(key: key);

  @override
  _AddFieldPageState createState() => _AddFieldPageState();
}

class _AddFieldPageState extends State<AddFieldPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _areaController = TextEditingController();
  File? _selectedFile;
  bool _isUploading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.fieldId != null) {
      _isEditing = true;
      fetchFieldDetails(widget.fieldId!);
    }
  }

  Future<void> fetchFieldDetails(int fieldId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/crops/api/fields/$fieldId/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      final fieldData = json.decode(response.body);
      setState(() {
        _nameController.text = fieldData['name'];
        _areaController.text = fieldData['area'].toString();
        // Assuming you handle image separately, you can load image URL here if needed
      });
    } else {
      print('Failed to load field details with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> _pickFile() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveField() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      final url = widget.fieldId == null
          ? '$baseUrl/crops/api/fields/create/'
          : '$baseUrl/crops/api/fields/${widget.fieldId}/edit/';

      final request = http.MultipartRequest(
        widget.fieldId == null ? 'POST' : 'PATCH',
        Uri.parse(url),
      );

      request.headers['Authorization'] = 'Token $token';
      request.fields['name'] = _nameController.text;
      request.fields['area'] = _areaController.text;

      if (_selectedFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _selectedFile!.path),
        );
      }

      final response = await request.send();

      setState(() {
        _isUploading = false;
      });

      final responseBody = await response.stream.bytesToString();
      final responseJson = json.decode(responseBody);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        String errorMessage = responseJson['error'] ?? 'Failed to save field';
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
                  "Your field has been ${_isEditing ? 'updated' : 'created'} successfully.",
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
          _isEditing ? 'Edit Field' : 'Add Field',
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
              GestureDetector(
                onTap: _pickFile,
                child: DottedBorder(
                  color: Color(0xFF0DA487),
                  strokeWidth: 2,
                  dashPattern: [6, 3],
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    child: _selectedFile == null
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload,
                              color: Color(0xFF0DA487), size: 50),
                          SizedBox(height: 10),
                          Text("Drag and drop here",
                              style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 5),
                          GestureDetector(
                            onTap: _pickFile,
                            child: Text(
                              "browse",
                              style: TextStyle(
                                color: Color(0xFF0DA487),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Stack(
                      children: [
                        Image.file(
                          _selectedFile!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          height: double.infinity,
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedFile = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Field Name',
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
                    return 'Please enter field name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _areaController,
                decoration: InputDecoration(
                  labelText: 'Field Area',
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
                    return 'Please enter field area';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveField,
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
