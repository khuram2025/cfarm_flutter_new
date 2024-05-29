import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fields.dart';
import 'feildADD.dart';
import 'feildDetailPage.dart';

const String baseUrl = 'http://farmapp.channab.com';

class FieldListPage extends StatefulWidget {
  @override
  _FieldListPageState createState() => _FieldListPageState();
}

class _FieldListPageState extends State<FieldListPage> {
  List<Field> fields = [];

  @override
  void initState() {
    super.initState();
    fetchFields();
  }

  Future<void> fetchFields() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/crops/api/fields/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> fieldsJson = json.decode(response.body);
      setState(() {
        fields = fieldsJson.map((json) => Field.fromJson(json)).toList();
      });
    } else {
      print('Failed to load fields with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Field List'),
        backgroundColor: Color(0xFF0DA487),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFieldPage()),
              ).then((_) {
                fetchFields(); // Refresh the field list after returning from AddFieldPage
              });
            },
          ),
        ],
      ),
      body: fields.isEmpty
          ? Center(child: Text('No fields available'))
          : ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, index) {
          final field = fields[index];
          return FieldCard(
            field: field,
            onFieldUpdated: fetchFields, // Pass the callback to refresh the list
          );
        },
      ),
    );
  }
}

class FieldCard extends StatelessWidget {
  final Field field;
  final VoidCallback onFieldUpdated; // Callback to refresh the list

  const FieldCard({Key? key, required this.field, required this.onFieldUpdated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FieldDetailPage(field: field),
          ),
        );
      },
      child: Card(
        child: SizedBox(
          height: 150,
          child: Row(
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: field.imageUrl != null
                    ? Image.network(
                  field.imageUrl!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 150,
                  height: 150,
                  color: Colors.grey,
                  child: Icon(Icons.image_not_supported),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            field.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF0DA487),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddFieldPage(fieldId: field.id),
                                    ),
                                  ).then((_) {
                                    onFieldUpdated(); // Refresh the field list after returning from AddFieldPage
                                  });
                                },
                                iconSize: 14,
                                color: Color(0xFF0DA487),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever_rounded),
                                onPressed: () {
                                  // Handle delete action for this field
                                },
                                iconSize: 16,
                                color: Colors.red,
                                padding: EdgeInsets.zero, // Remove any padding
                                constraints: BoxConstraints(), // Remove default constraints
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Area: ${field.area} acres',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MediumButton(
                            btnText: 'Field',
                            onPressed: () {
                              // Handle action for Field button
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MediumButton extends StatelessWidget {
  final String btnText;
  final VoidCallback onPressed;

  const MediumButton({required this.btnText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF0DA487),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        btnText,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


