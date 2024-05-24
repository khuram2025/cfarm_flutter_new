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

      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 6 Month Income & Expense',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0DA487)),
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
