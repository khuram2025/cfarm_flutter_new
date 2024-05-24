import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:untitled3/widgets/MediumButton.dart';
import '../utils/base.dart';

import '../utils/caluate_age.dart'; // Import the age calculator

class AnimalListCard extends StatelessWidget {
  const AnimalListCard({
    Key? key,
    required this.tag,
    required this.sex,
    required this.type,
    required this.status,
    required this.image,
    required this.dob,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  final String tag;
  final String sex;
  final String type;
  final String status;
  final String image;
  final DateTime dob; // Add this field
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card( // Use a Card widget for visual structure
      child: SizedBox(
        height: 150,
        child: Row(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Image.network(
                image,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
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
                          tag,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.edit),
                              onPressed: onEdit,
                              iconSize: 14,
                              color: AppColors.primary,
                              padding: EdgeInsets.zero, // Remove any padding
                              constraints: BoxConstraints(), // Remove default constraints
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever_rounded),
                              onPressed: onDelete,
                              iconSize: 16,
                              color: AppColors.tertiary,
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
                            text: '${type.isEmpty ? type : type[0].toUpperCase() + type.substring(1)}  ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),

                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Age: ${calculateAge(dob)}', // Dynamic age calculation
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MediumButton(
                          btnText: sex,
                          onPressed: () {
                            // Handle action for sex button
                          },
                        ),
                        MediumButton(
                          btnText: status,
                          onPressed: () {
                            // Handle action for status button
                          },
                        ),
                        MediumButton(
                          btnText: 'Cow',
                          onPressed: () {
                            // Handle action for 'Cow' button
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
    );
  }
}
