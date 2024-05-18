import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final String baseUrl = "http://192.168.8.153";

class AnimalFilterPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilter;

  AnimalFilterPage({required this.onApplyFilter});

  @override
  _AnimalFilterPageState createState() => _AnimalFilterPageState();
}

class _AnimalFilterPageState extends State<AnimalFilterPage> {
  String _selectedCategory = 'All';
  String _selectedType = 'All';
  int _minMonths = 0;
  int _maxMonths = 240; // 20 years in months
  bool _isMale = false;
  bool _isFemale = false;
  String _selectedStatus = 'active';

  List<String> _categories = ['All'];
  List<Map<String, dynamic>> _typesWithCounts = [];
  List<String> _types = ['All'];

  @override
  void initState() {
    super.initState();
    fetchCategoriesAndTypes();
  }

  Future<void> fetchCategoriesAndTypes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final categoriesResponse = await http.get(
      Uri.parse('$baseUrl/dairy/api/categories/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    final typesResponse = await http.get(
      Uri.parse('$baseUrl/dairy/api/types/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (categoriesResponse.statusCode == 200 && typesResponse.statusCode == 200) {
      List<dynamic> categoriesJson = json.decode(categoriesResponse.body);
      List<dynamic> typesJson = json.decode(typesResponse.body);

      setState(() {
        _categories = ['All'] + categoriesJson.map((c) => c['title'] as String).toList();
        _typesWithCounts = typesJson.map((t) => {'animal_type': t['animal_type'], 'count': t['count']}).toList();
        _types = ['All'] + _typesWithCounts.map((t) => "${t['animal_type']} (${t['count']})").toList();
      });
    } else {
      print('Failed to load categories and types');
      print('Categories Response: ${categoriesResponse.body}');
      print('Types Response: ${typesResponse.body}');
    }
  }

  void _applyFilters() {
    Map<String, dynamic> filters = {
      'category': _selectedCategory,
      'type': _selectedType,
      'minMonths': _minMonths,
      'maxMonths': _maxMonths,
      'sex': _isMale && _isFemale
          ? 'both'
          : _isMale
          ? 'male'
          : _isFemale
          ? 'female'
          : '',
      'status': _selectedStatus,
    };
    print('Applying filters: $filters');  // Add this print statement for debugging
    widget.onApplyFilter(filters);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animal Filter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Animal Filter Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue as String;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Animal Type',
                border: OutlineInputBorder(),
              ),
              items: _types.map((String type) {
                return DropdownMenuItem(
                  value: type.split(' ').first,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedType = newValue as String;
                });
              },
            ),
            SizedBox(height: 16),
            // Animal Age Filter in Months
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Animal Age (Months)', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _minMonths.toString(),
                        decoration: InputDecoration(
                          labelText: 'Min Months',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _minMonths = int.parse(value);
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _maxMonths.toString(),
                        decoration: InputDecoration(
                          labelText: 'Max Months',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _maxMonths = int.parse(value);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Sex', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Checkbox(
                  value: _isMale,
                  onChanged: (bool? value) {
                    setState(() {
                      _isMale = value!;
                    });
                  },
                ),
                Text('Male'),
                Checkbox(
                  value: _isFemale,
                  onChanged: (bool? value) {
                    setState(() {
                      _isFemale = value!;
                    });
                  },
                ),
                Text('Female'),
              ],
            ),
            SizedBox(height: 16),
            Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            Column(
              children: [
                RadioListTile<String>(
                  title: Text('Active'),
                  value: 'active',
                  groupValue: _selectedStatus,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text('Sold'),
                  value: 'sold',
                  groupValue: _selectedStatus,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text('Expired'),
                  value: 'expired',
                  groupValue: _selectedStatus,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: Text('Apply'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'All';
                      _selectedType = 'All';
                      _minMonths = 0;
                      _maxMonths = 240;
                      _isMale = false;
                      _isFemale = false;
                      _selectedStatus = 'active';
                    });
                  },
                  child: Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
