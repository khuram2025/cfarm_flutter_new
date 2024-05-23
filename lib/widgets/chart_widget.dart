import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../models/erpModels.dart';


class ChartWidget extends StatelessWidget {
  final Future<List<SummaryData>> summaryDataFuture;

  ChartWidget({required this.summaryDataFuture});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparison Chart',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            child: FutureBuilder<List<SummaryData>>(
              future: summaryDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load summary data: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available.'));
                } else {
                  final summaryData = snapshot.data!;
                  return SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(
                      numberFormat: NumberFormat.compact(),
                    ),
                    series: <CartesianSeries>[
                      ColumnSeries<SummaryData, String>(
                        color: Colors.green,
                        dataSource: summaryData,
                        xValueMapper: (SummaryData data, _) => data.month,
                        yValueMapper: (SummaryData data, _) => data.totalIncome,
                        name: 'Income',
                      ),
                      ColumnSeries<SummaryData, String>(
                        color: Colors.red,
                        dataSource: summaryData,
                        xValueMapper: (SummaryData data, _) => data.month,
                        yValueMapper: (SummaryData data, _) => data.totalExpense,
                        name: 'Expenses',
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
