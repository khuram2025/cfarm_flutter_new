import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:untitled3/widgets/MediumButton.dart';


class AnimalListCard extends StatelessWidget {
  const AnimalListCard({
    Key? key,
    required this.tag,
    required this.sex,
    required this.type,
    required this.status,
    required this.image,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  final String tag;
  final String sex;
  final String type;
  final String status;
  final String image;
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
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.edit),
                              onPressed: onEdit,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever_rounded),
                              onPressed: onDelete,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${type.isEmpty ? type : type[0].toUpperCase() + type.substring(1)} - ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const TextSpan(
                            text: '1 Year 2 months 30 Days', // This value should be dynamic in your app
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Similarly, make the "Age" dynamic in your application
                    const Text(
                      'Age: 1 Year 2 months 30 Days',
                      style: TextStyle(
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