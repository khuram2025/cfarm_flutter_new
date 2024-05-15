import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/animals.dart';
import '../widgets/animalListCard.dart';
import 'AnimalDetail.dart';
import 'animalFilterScreen.dart';

final String baseUrl = 'http://farmapp.channab.com';

class AnimalListMobilePage extends StatefulWidget {
  const AnimalListMobilePage({Key? key}) : super(key: key);

  @override
  State<AnimalListMobilePage> createState() => _AnimalListMobilePageState();
}

class _AnimalListMobilePageState extends State<AnimalListMobilePage> {
  List<Animal> animals = [];
  String? selectedType = 'All';
  Map<String, int> animalCounts = {
    'All': 0,
    'milking': 0,
    'pregnant': 0,
    'preg_milking': 0,
    'dry': 0,
    'breeder': 0,
    'other': 0,
  };

  @override
  void initState() {
    super.initState();
    fetchAnimalsAndCalculateCounts();
  }

  Future<void> fetchAnimalsAndCalculateCounts() async {
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
      List<Animal> fetchedAnimals = animalsJson.map((json) => Animal.fromJson(json)).toList();

      Map<String, int> counts = {
        'All': fetchedAnimals.length,
        'milking': fetchedAnimals.where((animal) => animal.animalType == 'milking').length,
        'preg_milking': fetchedAnimals.where((animal) => animal.animalType == 'preg_milking').length,
        'pregnant': fetchedAnimals.where((animal) => animal.animalType == 'pregnant').length,
        'dry': fetchedAnimals.where((animal) => animal.animalType == 'dry').length,
        'breeder': fetchedAnimals.where((animal) => animal.animalType == 'breeder').length,
        'other': fetchedAnimals.where((animal) => animal.animalType == 'other').length,
      };

      setState(() {
        animals = fetchedAnimals;
        animalCounts = counts;
      });
    } else {
      print('Failed to load animals with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> fetchAnimals([String type = 'All', Map<String, dynamic>? filters]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    String url = '$baseUrl/dairy/api/animals/?animal_type=$type';

    if (filters != null) {
      filters.forEach((key, value) {
        if (value is String && value != 'All') {
          url += '&$key=$value';
        } else if (value is Map<String, bool>) {
          value.forEach((subKey, subValue) {
            if (subValue) {
              url += '&$key=$subKey';
            }
          });
        } else if (value is int) {
          url += '&$key=$value';
        }
      });
    }

    print('Fetching animals with URL: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> animalsJson = json.decode(response.body);
      setState(() {
        animals = animalsJson.map((json) => Animal.fromJson(json)).toList();
        print('Fetched ${animals.length} animals');
      });
    } else {
      print('Failed to load animals with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _applyFilters(Map<String, dynamic> filters) {
    print('Filters applied: $filters'); // Add this print statement for debugging
    fetchAnimals('All', filters); // Apply the filters to fetch animals
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: Text('All (${animalCounts['All']})'),
                          selected: selectedType == 'All',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedType = 'All';
                              });
                              fetchAnimals('All');
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Milking (${animalCounts['milking']})'),
                          selected: selectedType == 'milking',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedType = 'milking';
                              });
                              fetchAnimals('milking');
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Preg-Milking (${animalCounts['preg_milking']})'),
                          selected: selectedType == 'preg_milking',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedType = 'preg_milking';
                              });
                              fetchAnimals('preg_milking');
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Pregnant (${animalCounts['pregnant']})'),
                          selected: selectedType == 'pregnant',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedType = 'pregnant';
                              });
                              fetchAnimals('pregnant');
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Dry (${animalCounts['dry']})'),
                          selected: selectedType == 'dry',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedType = 'dry';
                              });
                              fetchAnimals('dry');
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Breeder (${animalCounts['breeder']})'),
                          selected: selectedType == 'breeder',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedType = 'breeder';
                              });
                              fetchAnimals('breeder');
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Other (${animalCounts['other']})'),
                          selected: selectedType == 'other',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedType = 'other';
                              });
                              fetchAnimals('other');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Animal Filter Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnimalFilterPage(onApplyFilter: _applyFilters),
                      ),
                    );
                  },
                  child: Text('Filter'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: animals.length,
              itemBuilder: (context, index) {
                final animal = animals[index];

                return InkWell(
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
