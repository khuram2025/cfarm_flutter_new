import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../models/crops.dart';

const String baseUrl = 'http://farmapp.channab.com';

class HarvestEditPage extends StatefulWidget {
  final int cropId;
  final Harvest? harvest;

  const HarvestEditPage({Key? key, required this.cropId, this.harvest}) : super(key: key);

  @override
  _HarvestEditPageState createState() => _HarvestEditPageState();
}

class _HarvestEditPageState extends State<HarvestEditPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  DateTime? _endDate;
  late int _cutNumber;
  late TextEditingController _productionController;
  String _unit = 'kg';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.harvest?.startDate ?? DateTime.now();
    _endDate = widget.harvest?.endDate;
    _cutNumber = widget.harvest?.cutNumber ?? 1;
    _productionController = TextEditingController(text: widget.harvest?.production?.toString());
    _unit = widget.harvest?.unit ?? 'kg';

    if (widget.harvest == null) {
      _calculateNextCutNumber();
    }
  }

  Future<void> _calculateNextCutNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/crops/api/harvests/?crop=${widget.cropId}'),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      setState(() {
        _cutNumber = jsonResponse.length + 1;
      });
    } else {
      throw Exception('Failed to load harvests');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate ? _startDate : (_endDate ?? _startDate);
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveHarvest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      String url = widget.harvest == null
          ? '${baseUrl}/crops/api/harvests/'
          : '${baseUrl}/crops/api/harvests/${widget.harvest!.id}/';

      final response = await (widget.harvest == null ? http.post : http.put)(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
        body: jsonEncode({
          'crop': widget.cropId,
          'start_date': DateFormat('yyyy-MM-dd').format(_startDate),
          'end_date': _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null,
          'production': _productionController.text.isNotEmpty ? double.parse(_productionController.text) : null,
          'unit': _unit,
          'cut_number': _cutNumber,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        _showErrorDialog('Failed to save harvest. Please try again.');
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

  Widget _buildDateField(BuildContext context, String label, DateTime? date, bool isStartDate) {
    return InkWell(
      onTap: () => _selectDate(context, isStartDate),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
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
            Text(
              date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Not Set',
              style: TextStyle(color: Color(0xFF0DA487)),
            ),
            Icon(Icons.calendar_today, color: Color(0xFF0DA487)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.harvest == null ? 'Add Harvest' : 'Edit Harvest'),
        backgroundColor: Color(0xFF0DA487),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0DA487),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDateField(context, 'Start Date', _startDate, true),
              SizedBox(height: 10),
              _buildDateField(context, 'End Date', _endDate, false),
              SizedBox(height: 10),
              TextFormField(
                controller: _productionController,
                decoration: InputDecoration(
                  labelText: 'Production (optional)',
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
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _unit,
                onChanged: (String? newValue) {
                  setState(() {
                    _unit = newValue!;
                  });
                },
                items: ['kg', 'tons'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Unit',
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
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveHarvest,
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
