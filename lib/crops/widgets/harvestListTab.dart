import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../models/crops.dart';
import 'harvestEditPage.dart';  // Ensure you have this import for the edit page

const String baseUrl = 'http://farmapp.channab.com';

class HarvestListPage extends StatefulWidget {
  final int cropId;

  const HarvestListPage({Key? key, required this.cropId}) : super(key: key);

  @override
  _HarvestListPageState createState() => _HarvestListPageState();
}

class _HarvestListPageState extends State<HarvestListPage> {
  late Future<List<Harvest>> _harvestsFuture;

  @override
  void initState() {
    super.initState();
    _harvestsFuture = _fetchHarvests();
  }

  Future<List<Harvest>> _fetchHarvests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/crops/api/harvests/?crop=${widget.cropId}'),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((harvest) => Harvest.fromJson(harvest)).toList();
    } else {
      throw Exception('Failed to load harvests');
    }
  }

  Future<void> _deleteHarvestWithConfirmation(int harvestId) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('This item will be deleted permanently. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deleteHarvest(harvestId);
    }
  }

  Future<void> _deleteHarvest(int harvestId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.delete(
      Uri.parse('$baseUrl/crops/api/harvests/$harvestId/'),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        _harvestsFuture = _fetchHarvests(); // Refresh harvest list after deletion
      });
    } else {
      print('Failed to delete harvest with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> _editHarvest(Harvest harvest) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HarvestEditPage(cropId: widget.cropId, harvest: harvest)),
    );

    if (result == true) {
      setState(() {
        _harvestsFuture = _fetchHarvests(); // Refresh harvest list after editing
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Harvest>>(
      future: _harvestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No harvests found.'));
        } else {
          List<Harvest> harvests = snapshot.data!;
          harvests.sort((a, b) => b.startDate.compareTo(a.startDate)); // Sort by latest

          return ListView.builder(
            itemCount: harvests.length,
            itemBuilder: (context, index) {
              Harvest harvest = harvests[index];
              String startDate = "${harvest.startDate.toLocal()}".split(' ')[0];
              String endDate = harvest.endDate != null ? "${harvest.endDate!.toLocal()}".split(' ')[0] : 'Not Set';
              String daysBetween = harvest.endDate != null ? "${harvest.endDate!.difference(harvest.startDate).inDays} days" : 'N/A';

              return Container(
                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF0DA487)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$startDate - $endDate",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Color(0xFF0DA487), size: 16,),
                              onPressed: () {
                                _editHarvest(harvest);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red, size: 16,),
                              onPressed: () {
                                _deleteHarvestWithConfirmation(harvest.id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "${harvest.cutNumber} Cut Harvest",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFF0DA487),
                      ),
                    ),
                    Text(
                      "Total Production: ${harvest.production ?? 'N/A'} ${harvest.unit}",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Color(0xFF0DA487),
                      ),
                    ),
                    Text(
                      "Duration: $daysBetween",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Color(0xFF0DA487),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
