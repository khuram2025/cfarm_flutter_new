import 'package:flutter/material.dart';

class AnimalTypeFilter extends StatelessWidget {
  final String selectedType;
  final Map<String, int> animalCounts;
  final Function(String) onTypeSelected;

  const AnimalTypeFilter({
    Key? key,
    required this.selectedType,
    required this.animalCounts,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: animalCounts.entries.map((entry) {
                  String type = entry.key;
                  int count = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text('$type ($count)'),
                      selected: selectedType == type,
                      selectedColor: Color(0xFF0DA487).withOpacity(0.1),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selectedType == type ? Color(0xFF0DA487) : Colors.black,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          onTypeSelected(type);
                        }
                      },
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: Color(0xFF0DA487),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
