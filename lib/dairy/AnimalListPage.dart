import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/animalListCard.dart';

// Replace with your actual base URL
const String baseUrl = 'http://farmapp.channab.com';

class AnimalListMobilePage extends StatefulWidget {
  const AnimalListMobilePage({Key? key}) : super(key: key);

  @override
  State<AnimalListMobilePage> createState() => _AnimalListMobilePageState();
}

class _AnimalListMobilePageState extends State<AnimalListMobilePage> {
  List<Animal> animals = [];
  String? selectedStatus = 'All'; // Default to 'All'

  @override
  void initState() {
    super.initState();
    fetchAnimals();
  }

  Future<void> fetchAnimals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/dairy/api/animals/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> animalsJson = json.decode(response.body);
      setState(() {
        animals = animalsJson.map((json) => Animal.fromJson(json)).toList();
      });
    } else {
      print('Failed to load animals with status code: ${response.statusCode}');
      // Handle error, maybe show a snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal List'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Make it horizontally scrollable
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: selectedStatus == 'All',
                    onSelected: (selected) {
                      setState(() {
                        selectedStatus = 'All';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Milking'),
                    selected: selectedStatus == 'Milking',
                    onSelected: (selected) {
                      setState(() {
                        selectedStatus = 'Milking';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Prag-Milking'),
                    selected: selectedStatus == 'Prag-Milking',
                    onSelected: (selected) {
                      setState(() {
                        selectedStatus = 'Prag-Milking';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Dry'),
                    selected: selectedStatus == 'Dry',
                    onSelected: (selected) {
                      setState(() {
                        selectedStatus = 'Dry';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Breeder'),
                    selected: selectedStatus == 'Breeder',
                    onSelected: (selected) {
                      setState(() {
                        selectedStatus = 'Breeder';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: animals.length,
              itemBuilder: (context, index) {
                final animal = animals[index];

                // Filtering logic based on selected status
                if (selectedStatus != 'All' && animal.status != selectedStatus) {
                  return const SizedBox.shrink();
                }

                return InkWell( // Wrap with InkWell for tap functionality
                  onTap: () {
                    // Navigate to details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnimalDetailsPage(animal: animal),
                      ),
                    );
                  },
                  child: AnimalListCard(
                    tag: animal.tag,
                    sex: animal.sex,
                    type: animal.animalType,
                    status: animal.status,
                    image: animal.imagePath ?? '', // Provide a default or placeholder image if imagePath is null
                    onEdit: () {
                      // Handle edit action for this animal
                    },
                    onDelete: () {
                      // Handle delete action for this animal
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Animal Details Page
class AnimalDetailsPage extends StatelessWidget {
  final Animal animal;

  const AnimalDetailsPage({Key? key, required this.animal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(animal.tag),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (animal.imagePath != null)
              Image.network(animal.imagePath!),
            Text('Tag: ${animal.tag}'),
            Text('Type: ${animal.animalType}'),
            Text('Status: ${animal.status}'),
            Text('Sex: ${animal.sex}'),
            Text('DOB: ${animal.dob}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}

// Animal model
class Animal {
  final int id;
  final String tag;
  final DateTime dob;
  final double? latestWeight;
  final String animalType;
  final String status;
  final String sex;
  final String categoryTitle;
  final double? purchaseCost;
  final String? imagePath;

  Animal({
    required this.id,
    required this.tag,
    required this.dob,
    this.latestWeight,
    required this.animalType,
    required this.status,
    required this.sex,
    required this.categoryTitle,
    this.purchaseCost,
    this.imagePath,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    String imagePath = json['image'] as String? ?? '';
    String fullImagePath =
    imagePath.isNotEmpty ? baseUrl + imagePath : '';
    return Animal(
      id: json['id'] ?? 0,
      tag: json['tag'] ?? 'Unknown',
      dob: DateTime.parse(json['dob'] ?? '1900-01-01'),
      latestWeight: json['latest_weight'] != null
          ? double.tryParse(json['latest_weight'].toString())
          : null,
      animalType: json['animal_type'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
      sex: json['sex'] ?? 'Unknown',
      categoryTitle: json['category_title'] ?? 'Unknown',
      purchaseCost: json['purchase_cost'] != null
          ? double.tryParse(json['purchase_cost'].toString())
          : null,
      imagePath: fullImagePath,
    );
  }
}