import 'package:flutter/material.dart';

import '../models/animals.dart';


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
