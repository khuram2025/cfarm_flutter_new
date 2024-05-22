import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled3/Finance/addSalaryTransaction.dart';

import '../services/api_service.dart';

void main() {
  runApp(MaterialApp(
    home: TransactionEntryScreen(initialTabIndex: 0), // default to expense tab
  ));
}

class TransactionEntryScreen extends StatefulWidget {
  final int initialTabIndex;

  const TransactionEntryScreen({Key? key, required this.initialTabIndex}) : super(key: key);

  @override
  _TransactionEntryScreenState createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends State<TransactionEntryScreen> with SingleTickerProviderStateMixin {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  File? _selectedFile;
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _categoriesFuture = fetchCategories();
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

  Future<void> _createExpense() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (_formKey.currentState!.validate()) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://farmapp.channab.com/erp/api/expenses/create/'),
      );

      request.headers['Authorization'] = 'Token $token';
      request.fields['amount'] = _amountController.text;
      request.fields['date'] = DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_dateController.text));
      request.fields['category'] = _selectedCategory!;
      request.fields['description'] = _noteController.text;

      if (_selectedFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', _selectedFile!.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create expense')));
      }
    }
  }

  Future<void> _createIncome() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (_formKey.currentState!.validate()) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://farmapp.channab.com/erp/api/income/create/'),
      );

      request.headers['Authorization'] = 'Token $token';
      request.fields['amount'] = _amountController.text;
      request.fields['date'] = DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_dateController.text));
      request.fields['category'] = _selectedCategory!;
      request.fields['description'] = _noteController.text;

      if (_selectedFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', _selectedFile!.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create income')));
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
                  "Your transaction has been created successfully.",
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

  String _getTitle() {
    switch (_tabController.index) {
      case 0:
        return 'Add Expense';
      case 1:
        return 'Add Income';
      case 2:
        return 'Add Salary';
      default:
        return 'Add';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitle(),
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xFF0DA487),
              labelColor: Color(0xFF0DA487),
              unselectedLabelColor: Colors.grey,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Expense'),
                Tab(text: 'Income'),
                Tab(text: 'Salary'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForm('expense'),
          _buildForm('income'),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddSalaryTransactionScreen()),
              );
            },
            child: Container(
              color: Colors.white,
              child: Center(
                child: Text(
                  'Add Salary Transaction',
                  style: TextStyle(
                    color: Color(0xFF0DA487),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(String type) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'PKR',
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
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of spend',
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
            FutureBuilder<List<String>>(
              future: type == 'expense' ? _categoriesFuture : fetchIncomeCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Failed to load categories');
                } else {
                  final categories = snapshot.data!;
                  return DropdownButtonFormField(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Select Category',
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
                    items: categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category, style: TextStyle(color: Color(0xFF0DA487))),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue as String?;
                      });
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
            SizedBox(height: 10),
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
                        Icon(Icons.cloud_upload, color: Color(0xFF0DA487), size: 50),
                        SizedBox(height: 10),
                        Text("Drag and drop here", style: TextStyle(color: Colors.grey)),
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
                          icon: Icon(Icons.remove_circle, color: Colors.red),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (type == 'expense') {
                  _createExpense();
                } else if (type == 'income') {
                  _createIncome();
                }
              },
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
    );
  }
}
