import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final String baseUrl = "http://farmapp.channab.com";

class AnimalFilterPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilter;

  AnimalFilterPage({required this.onApplyFilter});

  @override
  _AnimalFilterPageState createState() => _AnimalFilterPageState();
}

class _AnimalFilterPageState extends State<AnimalFilterPage> {
  String _selectedCategory = 'All';
  String _selectedType = 'All';
  RangeValues _ageRange = const RangeValues(0, 20);
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
      'ageRange': _ageRange,
      'sex': {
        'male': _isMale,
        'female': _isFemale,
      },
      'status': _selectedStatus,
    };
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Animal Age (Years)', style: TextStyle(fontWeight: FontWeight.bold)),
                RangeSlider(
                  values: _ageRange,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  labels: RangeLabels(
                    '${_ageRange.start.round()}',
                    '${_ageRange.end.round()}',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _ageRange = values;
                    });
                  },
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
                      _ageRange = const RangeValues(0, 20);
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