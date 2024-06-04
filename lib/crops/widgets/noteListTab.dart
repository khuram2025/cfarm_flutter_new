import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/crops.dart';
import 'noteEditPage.dart';  // Ensure you have this import for the edit page

const String baseUrl = 'http://farmapp.channab.com';

class NotesListPage extends StatefulWidget {
  final int cropId;

  const NotesListPage({Key? key, required this.cropId}) : super(key: key);

  @override
  _NotesListPageState createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = _fetchNotes();
  }

  Future<List<Note>> _fetchNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/crops/api/crop-notes/?crop=${widget.cropId}'),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((note) => Note.fromJson(note)).toList();
    } else {
      throw Exception('Failed to load notes');
    }
  }

  Future<void> _deleteNoteWithConfirmation(int noteId) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('This item will be deleted permanently. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deleteNote(noteId);
    }
  }

  Future<void> _deleteNote(int noteId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.delete(
      Uri.parse('$baseUrl/crops/api/crop-notes/$noteId/'),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        _notesFuture = _fetchNotes(); // Refresh notes list after deletion
      });
    } else {
      print('Failed to delete note with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> _editNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditPage(note: note)),
    );

    if (result == true) {
      setState(() {
        _notesFuture = _fetchNotes(); // Refresh notes list after editing
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Note>>(
      future: _notesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No notes found.'));
        } else {
          List<Note> notes = snapshot.data!;
          notes.sort((a, b) => b.creationDate.compareTo(a.creationDate)); // Sort by latest

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              Note note = notes[index];
              DateTime noteDate = DateTime.parse(note.creationDate);
              String formattedDate = "${noteDate.hour}:${noteDate.minute} ${noteDate.hour >= 12 ? 'PM' : 'AM'} ${_dayOfWeek(noteDate.weekday)} ${noteDate.day} ${_month(noteDate.month)}, ${noteDate.year}";

              return Container(
                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF0DA487)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Color(0xFF0DA487), size: 16,),
                              onPressed: () {
                                _editNote(note);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red, size: 16,),
                              onPressed: () {
                                _deleteNoteWithConfirmation(note.id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    Text(
                      note.description,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFF0DA487),
                      ),
                    ),
                    if (note.image != null) SizedBox(height: 5.0),
                    if (note.image != null)
                      Image.network(note.image!),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  String _dayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _month(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}


