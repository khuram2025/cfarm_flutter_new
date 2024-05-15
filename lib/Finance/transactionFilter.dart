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
        title: Text('Filter Transactions'),
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
                border: OutlineInputBorder(),
              ),
              items: ['All', 'Income', 'Expense'].map((String type) {
                return DropdownMenuItem(
                  value: type,
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
            // Filter by Category
            DropdownButtonFormField(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Filter by Category',
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
            // Filter by Amount Range
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filter by Amount Range'),
                RangeSlider(
                  values: _amountRange,
                  min: 0,
                  max: 10000,
                  divisions: 100,
                  labels: RangeLabels('${_amountRange.start.round()}', '${_amountRange.end.round()}'),
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
                border: OutlineInputBorder(),
              ),
              items: _dateFilters.map((String filter) {
                return DropdownMenuItem(
                  value: filter,
                  child: Text(filter),
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
                child: Text('From: ${DateFormat('yyyy-MM-dd').format(_customDateRange!.start)} To: ${DateFormat('yyyy-MM-dd').format(_customDateRange!.end)}'),
              ),
            SizedBox(height: 16),
            // Apply and Reset Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: Text('Apply'),
                ),
                ElevatedButton(
                  onPressed: _resetFilters,
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
