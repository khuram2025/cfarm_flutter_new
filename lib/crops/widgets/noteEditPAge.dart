import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/crops.dart';

const String baseUrl = 'http://farmapp.channab.com';

class NoteEditPage extends StatefulWidget {
  final Note note;

  const NoteEditPage({Key? key, required this.note}) : super(key: key);

  @override
  _NoteEditPageState createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.note.description);
    _selectedDate = DateTime.parse(widget.note.creationDate);
  }

  Future<void> _updateNote() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.put(
      Uri.parse('$baseUrl/crops/api/crop-notes/${widget.note.id}/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: jsonEncode({
        'crop': widget.note.crop,
        'description': _descriptionController.text,
        'creation_date': _selectedDate.toIso8601String(),
        'image': widget.note.image,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // Indicate that the note was updated
    } else {
      print('Failed to update note with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
        backgroundColor: Color(0xFF0DA487),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Text(
                  'Date: ',
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate)
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                  },
                  child: Text(
                    "${_selectedDate.toLocal()}".split(' ')[0],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0DA487),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0DA487),
              ),
              onPressed: _updateNote,
              child: Text('Save Note'),
            ),
          ],
        ),
      ),
    );
  }
}
