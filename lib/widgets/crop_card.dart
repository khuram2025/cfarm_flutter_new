import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../crops/cropDetailPage.dart';
import '../models/fields.dart';



class CropCard extends StatelessWidget {
  final Crop crop;

  const CropCard({Key? key, required this.crop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CropDetailPage(crop: crop),
          ),
        );
      },
      child: Card(
        child: SizedBox(
          height: 150,
          child: Row(
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: crop.fieldImageUrl != null
                    ? Image.network(
                  crop.fieldImageUrl!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 150,
                  height: 150,
                  color: Colors.grey,
                  child: Icon(Icons.image_not_supported),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF0DA487),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Variety: ${crop.variety}'),
                      Text('Planting Date: ${crop.plantingDate}'),
                      Text('Stage: ${crop.stage}'),
                      // Placeholder for future fields
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
