import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/animals.dart';

class MilkChart extends StatelessWidget {
  final List<MilkRecord> milkRecords;

  MilkChart({required this.milkRecords});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(toY: milkRecords.fold(0, (sum, record) => sum + record.firstTime), color: Colors.red),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(toY: milkRecords.fold(0, (sum, record) => sum + record.secondTime), color: Colors.green),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(toY: milkRecords.fold(0, (sum, record) => sum + record.thirdTime), color: Colors.blue),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(toY: milkRecords.fold(0, (sum, record) => sum + record.totalMilk), color: Colors.purple),
            ],
          ),
        ],
      ),
    );
  }
}
