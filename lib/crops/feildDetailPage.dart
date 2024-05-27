import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../home/customDrawer.dart';
import '../models/fields.dart';
import '../widgets/MediumButton.dart';
import '../widgets/crop_card.dart';

const String baseUrl = 'http://farmapp.channab.com';

class FieldDetailPage extends StatefulWidget {
  final Field field;

  const FieldDetailPage({Key? key, required this.field}) : super(key: key);

  @override
  _FieldDetailPageState createState() => _FieldDetailPageState();
}

class _FieldDetailPageState extends State<FieldDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Crop> crops = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchCrops();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchCrops() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/crops/api/fields/${widget.field.id}/crops/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> cropsJson = json.decode(response.body);
      setState(() {
        crops = cropsJson.map((json) => Crop.fromJson(json)).toList();
      });
    } else {
      print('Failed to load crops with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  List<Widget> _buildTabs() {
    return [
      Tab(text: 'Info'),
      Tab(text: 'Crops History'),
    ];
  }

  List<Widget> _buildTabViews() {
    return [
      _buildInfoTab(),
      _buildCropsHistoryTab(),
    ];
  }

  Widget _buildInfoTab() {
    return Center(
      child: Text('Field Info: ${widget.field.name}'),
    );
  }

  Widget _buildCropsHistoryTab() {
    return crops.isEmpty
        ? Center(child: Text('No crops history available for this field'))
        : ListView.builder(
      itemCount: crops.length,
      itemBuilder: (context, index) {
        final crop = crops[index];
        return CropCard(crop: crop);
      },
    );
  }

  Future<void> _deleteField() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.delete(
      Uri.parse('$baseUrl/crops/api/fields/${widget.field.id}/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 204) {
      Navigator.pop(context, true); // Indicate that the field was deleted
    } else {
      print('Failed to delete field with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _editField() {
    // Navigate to the edit field page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.field.imageUrl != null
                        ? Image.network(
                      widget.field.imageUrl!,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      color: Colors.grey,
                      child: Icon(Icons.image_not_supported),
                    ),
                    Positioned(
                      top: 30.0,
                      left: 10.0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.field.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0DA487),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.edit),
                        onPressed: _editField,
                        color: Color(0xFF0DA487),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever_rounded),
                        onPressed: _deleteField,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  tabs: _buildTabs(),
                  labelColor: Colors.white,
                  unselectedLabelColor: Color(0xFF0DA487),
                  indicator: BoxDecoration(
                    color: Color(0xFF0DA487),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _buildTabViews().map((Widget tabView) {
                    return Container(
                      color: Colors.white,
                      child: tabView,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



