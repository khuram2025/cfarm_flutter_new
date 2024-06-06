import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled3/dairy/widgets/milkChart.dart';

import '../apis/dairy.dart';
import '../models/animals.dart';

class MilkRecordList extends StatefulWidget {
  @override
  _MilkRecordListState createState() => _MilkRecordListState();
}

class _MilkRecordListState extends State<MilkRecordList> {
  late Future<List<MilkRecord>> futureMilkRecords;

  @override
  void initState() {
    super.initState();
    futureMilkRecords = fetchMilkRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Milk Records'),
      ),
      body: FutureBuilder<List<MilkRecord>>(
        future: futureMilkRecords,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<MilkRecord> milkRecords = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: milkRecords.length,
                    itemBuilder: (context, index) {
                      MilkRecord record = milkRecords[index];
                      return ListTile(
                        title: Text(record.date),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Animal Tag: ${record.animalTag}'),
                            Text('1st Time Milk: ${record.firstTime} liters'),
                            Text('2nd Time Milk: ${record.secondTime} liters'),
                            Text('3rd Time Milk: ${record.thirdTime} liters'),
                            Text('Total Milk: ${record.totalMilk} liters'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: MilkChart(milkRecords: milkRecords),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
