import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../home/customDrawer.dart';
import '../home/finCustomeAppbar.dart';
import '../apis/models.dart';  // Ensure you are importing from the correct file
import '../widgets/AnimalChipRow.dart';
import '../widgets/animalListCard.dart';
import 'AnimalDetail.dart';
import 'addAnimalPage.dart';
import 'animalFilterScreen.dart';

const String baseUrl = 'http://farmapp.channab.com';

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

  void _handleTypeSelected(String type) {
    setState(() {
      selectedType = type;
      fetchAnimals(type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FinCustomAppBar(
        title: 'Animal List',
        onAddTransaction: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAnimalPage(),
            ),
          );
        },
        onFilter: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimalFilterPage(onApplyFilter: _applyFilters),
            ),
          );
        },
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          AnimalTypeFilter(
            selectedType: selectedType!,
            animalCounts: animalCounts,
            onTypeSelected: _handleTypeSelected,
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
                        builder: (context) => AnimalDetailPage(animal: animal,),
                      ),
                    );
                  },
                  child: AnimalListCard(
                    tag: animal.tag,
                    sex: animal.sex,
                    type: animal.animalType,
                    status: animal.status,
                    image: animal.imagePath ?? '', // Provide a default or placeholder image if imagePath is null
                    dob: animal.dob, // Pass the date of birth
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
