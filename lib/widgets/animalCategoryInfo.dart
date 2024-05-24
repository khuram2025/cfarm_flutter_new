import 'package:flutter/material.dart';

class AnimalCategoryInfo extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final Map<String, Color> categoryColorMap;

  AnimalCategoryInfo({required this.categories, required this.categoryColorMap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: categories.map((category) {
        final color = categoryColorMap[category['category']] ?? Colors.grey;
        final count = category['count'];
        return Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              Text(
                '${category['category']} ($count)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
