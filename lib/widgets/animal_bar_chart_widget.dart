import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnimalBarChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> animalTypes;
  final List<Map<String, dynamic>> animalCategories;

  AnimalBarChartWidget({required this.animalTypes, required this.animalCategories});

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = animalTypes
        .map((entry) => ChartData(entry['animal_type'], entry['count']))
        .toList();

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
      case 'milking':
        return Color(0xFF0DA487);
      case 'preg_milking':
        return Color(0xFFE91E63);
      case 'dry':
        return Color(0xFF795548);
      case 'breeder':
        return Color(0xFFFF9800);
      case 'Other':
        return Color(0xFF9E9E9E);
      case 'calf':
        return Color(0xFF2196F3);
      default:
        return Color(0xFF9E9E9E);
    }
  }
}
