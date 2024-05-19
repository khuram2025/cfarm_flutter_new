import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';
import '../services/api_service.dart';

class FilterPageWidget extends StatefulWidget {
  const FilterPageWidget({Key? key}) : super(key: key);

  @override
  _FilterPageWidgetState createState() => _FilterPageWidgetState();
}

class _FilterPageWidgetState extends State<FilterPageWidget> {
  String _selectedType = 'All';
  String _selectedCategory = 'All';
  RangeValues _amountRange = const RangeValues(0, 10000);
  String _selectedDateFilter = 'All';
  DateTimeRange? _customDateRange;

  List<String> _categories = ['All'];
  final List<String> _dateFilters = [
    'All',
    'Last Week',
    'This Month',
    'Last Month',
    'This Year',
    'Last Year',
    'Custom Date Range'
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      List<String> categories = await fetchCategories();
      setState(() {
        _categories = ['All'] + categories;
      });
    } catch (e) {
      print('Failed to load categories: $e');
    }
  }

  Future<void> _pickCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: _customDateRange ?? DateTimeRange(start: DateTime.now(), end: DateTime.now().add(Duration(days: 7))),
    );
    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedDateFilter = 'Custom Date Range';
      });
    }
  }

  void _applyFilters() {
    final filterModel = FilterModel(
      type: _selectedType,
      category: _selectedCategory,
      amountRange: _amountRange,
      dateFilter: _selectedDateFilter,
      customDateRange: _customDateRange,
    );
    Navigator.pop(context, filterModel);
  }

  void _resetFilters() {
    setState(() {
      _selectedType = 'All';
      _selectedCategory = 'All';
      _amountRange = const RangeValues(0, 10000);
      _selectedDateFilter = 'All';
      _customDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Filter Transactions',
          style: TextStyle(color: Color(0xFF0DA487)),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF0DA487)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Filter by Type
            DropdownButtonFormField(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Filter by Type',
                labelStyle: TextStyle(color: Color(0xFF0DA487)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0DA487)),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0DA487)),
                ),
              ),
              items: ['All', 'Income', 'Expense'].map((String type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type, style: TextStyle(color: Color(0xFF0DA487))),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedType = newValue as String;
                });
              },
            ),
            SizedBox(height: 16),
            // Filter by Category
            DropdownButtonFormField(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Filter by Category',
                labelStyle: TextStyle(color: Color(0xFF0DA487)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0DA487)),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0DA487)),
                ),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category, style: TextStyle(color: Color(0xFF0DA487))),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue as String;
                });
              },
            ),
            SizedBox(height: 16),
            // Filter by Amount Range
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Amount Range',
                  style: TextStyle(color: Color(0xFF0DA487)),
                ),
                RangeSlider(
                  values: _amountRange,
                  min: 0,
                  max: 10000,
                  divisions: 100,
                  activeColor: Color(0xFF0DA487),
                  inactiveColor: Color(0xFF0DA487).withOpacity(0.3),
                  labels: RangeLabels(
                    '${_amountRange.start.round()}',
                    '${_amountRange.end.round()}',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _amountRange = values;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            // Date Filter
            DropdownButtonFormField(
              value: _selectedDateFilter,
              decoration: InputDecoration(
                labelText: 'Filter by Date',
                labelStyle: TextStyle(color: Color(0xFF0DA487)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0DA487)),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0DA487)),
                ),
              ),
              items: _dateFilters.map((String filter) {
                return DropdownMenuItem(
                  value: filter,
                  child: Text(filter, style: TextStyle(color: Color(0xFF0DA487))),
                );
              }).toList(),
              onChanged: (newValue) async {
                if (newValue == 'Custom Date Range') {
                  await _pickCustomDateRange(context);
                } else {
                  setState(() {
                    _selectedDateFilter = newValue as String;
                    _customDateRange = null; // Reset custom date range if another filter is selected
                  });
                }
              },
            ),
            if (_selectedDateFilter == 'Custom Date Range' && _customDateRange != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'From: ${DateFormat('yyyy-MM-dd').format(_customDateRange!.start)} To: ${DateFormat('yyyy-MM-dd').format(_customDateRange!.end)}',
                  style: TextStyle(color: Color(0xFF0DA487)),
                ),
              ),
            SizedBox(height: 16),
            // Apply and Reset Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0DA487),
                  ),
                  child: Text('Apply', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _resetFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0DA487),
                  ),
                  child: Text('Reset', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
