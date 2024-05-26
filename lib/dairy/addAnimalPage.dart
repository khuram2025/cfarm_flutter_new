import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'addAnimalCategory.dart';

void main() {
  runApp(MaterialApp(
    home: AddAnimalPage(),
  ));
}

class AddAnimalPage extends StatefulWidget {
  @override
  _AddAnimalPageState createState() => _AddAnimalPageState();
}

class _AddAnimalPageState extends State<AddAnimalPage> {
  TextEditingController _tagController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  File? _selectedFile;
  bool _isUploading = false;
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  String? _selectedSex;
  String? _selectedStatus = 'active';
  String? _selectedType;
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _dobController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _priceController.text = '0';
    _categoriesFuture = fetchCategories();
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
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickFile() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() async {
        _selectedFile = await _compressImage(File(pickedFile.path));
      });
    }
  }

  Future<void> _takePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() async {
        _selectedFile = await _compressImage(File(pickedFile.path));
      });
    }
  }

  Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;
    final resizedImage = img.copyResize(image, width: 800);
    final compressedBytes = img.encodeJpg(resizedImage, quality: 70);
    final compressedFile = File(file.path)..writeAsBytesSync(compressedBytes);
    return compressedFile;
  }

  Future<void> _createAnimal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://34.207.117.85:8001/dairy/api/animals/create/'),
      );

      request.headers['Authorization'] = 'Token $token';
      request.fields['tag'] = _tagController.text;
      request.fields['purchase_cost'] = _priceController.text;
      request.fields['dob'] = DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_dobController.text));
      request.fields['category'] = _selectedCategory!;
      request.fields['sex'] = _selectedSex!.toLowerCase(); // Ensure it is lowercase
      request.fields['status'] = _selectedStatus!.toLowerCase(); // Ensure it is lowercase
      request.fields['animal_type'] = _selectedType!;

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

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        String errorMessage = responseJson['error'] ?? 'Failed to create animal';
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
                  "Your animal has been created successfully.",
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

  Future<List<String>> fetchCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('http://34.207.117.85:8001/dairy/api/categories/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> categoriesJson = json.decode(response.body);
      List<String> categories = categoriesJson.map<String>((category) => category['title']).toList();
      categories.add("Add Category"); // Adding the "Add Category" option
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Animal',
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
                controller: _tagController,
                decoration: InputDecoration(
                  labelText: 'Animal Tag',
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
                    return 'Please enter animal tag';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<List<String>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Failed to load categories');
                        } else {
                          final categories = snapshot.data!;
                          return DropdownButtonFormField(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0xFF0DA487)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0xFF0DA487)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0xFF0DA487)),
                              ),
                              labelStyle:
                              TextStyle(color: Color(0xFF0DA487)),
                            ),
                            items: categories.map((String category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Container(
                                  color: category == "Add Category"
                                      ? Color(0xFF0DA487)
                                      : Colors.white,
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: category == "Add Category"
                                          ? Colors.white
                                          : Color(0xFF0DA487),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              if (newValue == "Add Category") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddCategoryPage(),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _selectedCategory = newValue as String?;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedSex,
                      decoration: InputDecoration(
                        labelText: 'Sex',
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
                      items: ['Male', 'Female'].map((String sex) {
                        return DropdownMenuItem(
                          value: sex.toLowerCase(),
                          child: Text(sex,
                              style: TextStyle(color: Color(0xFF0DA487))),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSex = newValue as String?;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select sex';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
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
                    return 'Please enter price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
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
                      Text(_dobController.text,
                          style: TextStyle(color: Color(0xFF0DA487))),
                      Icon(Icons.calendar_today,
                          color: Color(0xFF0DA487)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
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
                      items: ['Active', 'Expired', 'Sold'].map((String status) {
                        return DropdownMenuItem(
                          value: status.toLowerCase(),
                          child: Text(status,
                              style: TextStyle(color: Color(0xFF0DA487))),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedStatus = newValue as String?;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a status';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Type',
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
                      items: [
                        'Breeder',
                        'Pregnant',
                        'Dry',
                        'Milking',
                        'Preg_milking',
                        'Calf',
                        'Other'
                      ].map((String type) {
                        return DropdownMenuItem(
                          value: type.toLowerCase(),
                          child: Text(type,
                              style: TextStyle(color: Color(0xFF0DA487))),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedType = newValue as String?;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a type';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createAnimal,
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

