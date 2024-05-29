import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/animals.dart';

const String baseUrl = 'http://farmapp.channab.com';

class AnimalWeightListPage extends StatefulWidget {
  @override
  _AnimalWeightListPageState createState() => _AnimalWeightListPageState();
}

class _AnimalWeightListPageState extends State<AnimalWeightListPage> {
  late Future<List<AnimalWeightRecord>> _weightRecordsFuture;

  @override
  void initState() {
    super.initState();
    _weightRecordsFuture = fetchAnimalWeightRecords();
  }

  Future<List<AnimalWeightRecord>> fetchAnimalWeightRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/dairy/api/animal-weights/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> recordsJson = json.decode(response.body);
      return recordsJson.map((json) => AnimalWeightRecord.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load animal weight records');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animal Weights'),
        backgroundColor: Color(0xFF0DA487),
      ),
      body: FutureBuilder<List<AnimalWeightRecord>>(
        future: _weightRecordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load records'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No records available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final record = snapshot.data![index];
                return AnimalWeightRecordCard(record: record);
              },
            );
          }
        },
      ),
    );
  }
}

class AnimalWeightRecordCard extends StatelessWidget {
  final AnimalWeightRecord record;

  const AnimalWeightRecordCard({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.date,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tag: ${record.animalTag}'),
                Text('Weight: ${record.weightKg} kg'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AnimalWeightDetailDialog(record: record),
                    );
                  },
                  child: Text(
                    'Details',
                    style: TextStyle(color: Color(0xFF0DA487)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnimalWeightDetailDialog extends StatelessWidget {
  final AnimalWeightRecord record;

  const AnimalWeightDetailDialog({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Animal Weight Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tag: ${record.animalTag}'),
          Text('Weight: ${record.weightKg} kg'),
          Text('Date: ${record.date}'),
          Text('Description: ${record.description ?? "N/A"}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: Color(0xFF0DA487))),
        ),
      ],
    );
  }
}
