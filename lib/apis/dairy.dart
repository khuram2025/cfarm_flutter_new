import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/animals.dart';


Future<List<MilkRecord>> fetchMilkRecords() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  final response = await http.get(
    Uri.parse('http://farmapp.channab.com/dairy/api/animal_milk/'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Token $token",
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((record) => MilkRecord.fromJson(record)).toList();
  } else {
    print('Failed to load milk records with status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Failed to load milk records');
  }
}
