import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'TextOverlayPainter.dart';

class AnimalBarChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> animalTypes;
  final List<Map<String, dynamic>> animalCategories;

  AnimalBarChartWidget({required this.animalTypes, required this.animalCategories});

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = animalTypes
        .map((entry) => ChartData(entry['animal_type'], entry['count']))
        .toList();

    String allText = "All ${animalCategories.fold<int>(0, (sum, item) => sum + (item['count'] as int))}";
    String cowText = "Cow ${animalCategories.firstWhere((element) => element['category'] == 'Cow', orElse: () => {'count': 0})['count']}";
    String buffaloText = "Buffalo ${animalCategories.firstWhere((element) => element['category'] == 'Buffalo', orElse: () => {'count': 0})['count']}";

    return Column(
      children: [
        Container(
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(),
            series: <CartesianSeries>[
              ColumnSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.category,
                yValueMapper: (ChartData data, _) => data.count,
                pointColorMapper: (ChartData data, _) => data.color,
                dataLabelSettings: DataLabelSettings(isVisible: true),
              )
            ],
          ),
        ),
        SizedBox(height: 8),
        CustomPaint(
          size: Size(double.infinity, 30), // Adjust height as needed
          painter: TextOverlayPainter(allText, cowText, buffaloText),
        ),
      ],
    );
  }
}

class ChartData {
  ChartData(this.category, this.count)
      : color = _getColorForCategory(category);

  final String category;
  final int count;
  final Color color;

  static Color _getColorForCategory(String category) {
    switch (category) {
      case 'Milking':
        return Colors.green;
      case 'Pregnant':
        return Colors.pink;
      case 'Dry':
        return Colors.brown;
      case 'Breeder':
        return Colors.orange;
      case 'Other':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
