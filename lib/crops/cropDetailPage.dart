import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../home/customDrawer.dart';
import '../models/fields.dart';
import '../widgets/CropActivityCard.dart';
import '../widgets/crop_card.dart';

const String baseUrl = 'http://farmapp.channab.com';

class CropDetailPage extends StatefulWidget {
  final Crop crop;

  const CropDetailPage({Key? key, required this.crop}) : super(key: key);

  @override
  _CropDetailPageState createState() => _CropDetailPageState();
}

class _CropDetailPageState extends State<CropDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CropActivity> activities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    fetchCropActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchCropActivities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/crops/api/crops/${widget.crop.id}/activities/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> activitiesJson = json.decode(response.body);
      setState(() {
        activities = activitiesJson.map((json) => CropActivity.fromJson(json)).toList();
      });
    } else {
      print('Failed to load crop activities with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  List<Widget> _buildTabs() {
    return [
      Tab(text: 'Info'),
      Tab(text: 'Crops Activity'),
      Tab(text: 'Notes'),
      Tab(text: 'Harvesting'),
      Tab(text: 'Gallery'),
    ];
  }

  List<Widget> _buildTabViews() {
    return [
      _buildInfoTab(),
      _buildCropsActivityTab(),
      _buildNotesTab(),
      _buildHarvestingTab(),
      _buildGalleryTab(),
    ];
  }

  Widget _buildInfoTab() {
    return Center(
      child: Text('Crop Info: ${widget.crop.name}'),
    );
  }

  Widget _buildCropsActivityTab() {
    return activities.isEmpty
        ? Center(child: Text('No activities available for this crop'))
        : ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return CropActivityCard(activity: activity);
      },
    );
  }

  Widget _buildNotesTab() {
    return Center(
      child: Text('Notes for Crop: ${widget.crop.name}'),
    );
  }

  Widget _buildHarvestingTab() {
    return Center(
      child: Text('Harvesting Info for Crop: ${widget.crop.name}'),
    );
  }

  Widget _buildGalleryTab() {
    return Center(
      child: Text('Gallery for Crop: ${widget.crop.name}'),
    );
  }

  Future<void> _deleteCrop() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.delete(
      Uri.parse('$baseUrl/crops/api/crops/${widget.crop.id}/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 204) {
      Navigator.pop(context, true); // Indicate that the crop was deleted
    } else {
      print('Failed to delete crop with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _editCrop() {
    // Navigate to the edit crop page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: DefaultTabController(
        length: 5,
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
                    widget.crop.fieldImageUrl != null
                        ? Image.network(
                      widget.crop.fieldImageUrl!,
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
                      widget.crop.name,
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
                        onPressed: _editCrop,
                        color: Color(0xFF0DA487),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever_rounded),
                        onPressed: _deleteCrop,
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
