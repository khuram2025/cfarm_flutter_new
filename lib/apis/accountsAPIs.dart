import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'models.dart';

class ApiService {
  final String baseUrl = "http://farmapp.channab.com";

  Future<Map<String, dynamic>?> loginUser(String mobileNumber, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts/api/login/'),
      body: {
        'username': mobileNumber,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String? token = data['token'];  // Assuming the token is returned with the key 'token'
      if (token != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
      }
      return data;
    }
  }


  Future<List<Animal>> fetchAnimals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('http://farmapp.channab.com/dairy/api/animals/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> animalsJson = json.decode(response.body) as List;
      return animalsJson.map((json) => Animal.fromJson(json)).toList();
    } else {
      print('Failed to load animals with status code: ${response.statusCode}');
      throw Exception('Failed to load animals with status code: ${response.statusCode}');
    }
  }

  Future<List<Expense>> fetchExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('http://farmapp.channab.com/dairy/api/expenses/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> expensesJson = json.decode(response.body) as List;
      return expensesJson.map((json) => Expense.fromJson(json)).toList();
    } else {
      print('Failed to load expenses with status code: ${response.statusCode}');
      throw Exception('Failed to load expenses with status code: ${response.statusCode}');
    }
  }



  Future<List<Animal>> fetchAnimalsByType(String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    String url = type == 'All' ? '$baseUrl/dairy/api/animals/' : '$baseUrl/dairy/api/animals/?type=$type';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> animalsJson = json.decode(response.body) as List;
      return animalsJson.map((json) => Animal.fromJson(json)).toList();
    } else {
      print('Failed to load animals with status code: ${response.statusCode}');
      throw Exception('Failed to load animals with status code: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAnimalTypes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/dairy/api/animal_types/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      print('Failed to load animal types with status code: ${response.statusCode}');
      throw Exception('Failed to load animal types');
    }
  }

  Future<List<MilkingData>> fetchMilkingData(int animalId, String filter, {DateTime? from, DateTime? to}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    String url;
    if (filter == 'Custom Range' && from != null && to != null) {
      String formattedFrom = DateFormat('yyyy-MM-dd').format(from);
      String formattedTo = DateFormat('yyyy-MM-dd').format(to);
      url = '$baseUrl/dairy/api/milk_records/$animalId/?from=$formattedFrom&to=$formattedTo';
    } else {
      url = '$baseUrl/dairy/api/milk_records/$animalId/?filter=$filter';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> milkRecordsJson = json.decode(response.body) as List;
      return milkRecordsJson.map((json) => MilkingData.fromJson(json)).toList();
    } else {
      print('Failed to load milking data with status code: ${response.statusCode}');
      throw Exception('Failed to load milking data with status code: ${response.statusCode}');
    }
  }

  Future<List<MilkingRecord>> fetchTotalMilkingData(String filter, {DateTime? from, DateTime? to}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    String url;
    if (filter == 'Custom Range' && from != null && to != null) {
      String formattedFrom = DateFormat('yyyy-MM-dd').format(from);
      String formattedTo = DateFormat('yyyy-MM-dd').format(to);
      url = '$baseUrl/dairy/api/milk_records/?from=$formattedFrom&to=$formattedTo';
    } else {
      url = '$baseUrl/dairy/api/milk_records/?filter=$filter';
    }
    print("Request URL: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      print("Raw JSON response: ${response.body}");
      var jsonResponse = json.decode(response.body);
      List<dynamic> milkRecordsJson = jsonResponse['records'] as List;
      return milkRecordsJson.map((json) => MilkingRecord.fromJson(json)).toList();
    } else {
      print('Failed to load milking data with status code: ${response.statusCode}');
      throw Exception('Failed to load milking data');
    }
  }

  Future<bool> createOrUpdateMilkRecord({
    required DateTime date,
    required int animalId,
    double? firstTime,
    double? secondTime,
    double? thirdTime,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String url = '$baseUrl/dairy/api/milk_records/create/';

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    Map<String, dynamic> data = {
      'date': formattedDate,
      'animal': animalId,
      'first_time': firstTime,
      'second_time': secondTime,
      'third_time': thirdTime,
    };

    // Log data being sent
    print("Sending Milk Record Data:\n$data");

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      print("Milk record created/updated successfully.");
      return true;
    } else {
      // Log detailed error information
      print('Failed to create/update milk record with status code: ${response.statusCode}');
      print('Error Response: ${response.body}'); // Includes backend error messages
      return false;
    }
  }


  Future<List<Animal>> fetchMilkAnimals() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final response = await http.get(
      Uri.parse('$baseUrl/dairy/api/animals/filtered/'), // Corrected from '$_baseUrl' to '$baseUrl'
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> animalList = json.decode(response.body);
      return animalList.map((data) => Animal.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load animals');
    }
  }


}