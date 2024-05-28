import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'taskListPage.dart';
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

class _CropDetailPageState extends State<CropDetailPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _activityTabController;
  List<CropActivity> activities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _activityTabController = TabController(length: 2, vsync: this);
    fetchCropActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _activityTabController.dispose();
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

  Future<void> updateActivityStatus(int activityId, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.patch(
      Uri.parse('$baseUrl/crops/api/activities/$activityId/status/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      setState(() {
        fetchCropActivities();
      });
      print('Activity status updated successfully');
    } else {
      print('Failed to update activity status with status code: ${response.statusCode}');
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
      Tab(text: 'Tasks'),
    ];
  }

  List<Widget> _buildActivityTabs() {
    return [
      Tab(text: 'Upcoming'),
      Tab(text: 'Previous'),
    ];
  }

  List<Widget> _buildTabViews() {
    return [
      _buildInfoTab(),
      _buildCropsActivityTab(),
      _buildNotesTab(),
      _buildHarvestingTab(),
      _buildGalleryTab(),
      _buildTasksTab(),
    ];
  }

  List<Widget> _buildActivityTabViews() {
    return [
      _buildUpcomingActivitiesTab(),
      _buildPreviousActivitiesTab(),
    ];
  }

  Widget _buildInfoTab() {
    return Center(
      child: Text('Crop Info: ${widget.crop.name}'),
    );
  }

  Widget _buildCropsActivityTab() {
    return Column(
      children: [
        TabBar(
          controller: _activityTabController,
          tabs: _buildActivityTabs(),
          labelColor: Colors.white,
          unselectedLabelColor: Color(0xFF0DA487),
          indicator: BoxDecoration(
            color: Color(0xFF0DA487),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _activityTabController,
            children: _buildActivityTabViews(),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingActivitiesTab() {
    final upcomingActivities = activities.where((activity) => activity.status == 'pending').toList();

    return upcomingActivities.isEmpty
        ? Center(child: Text('No upcoming activities for this crop'))
        : ListView.builder(
      itemCount: upcomingActivities.length,
      itemBuilder: (context, index) {
        final activity = upcomingActivities[index];
        return CropActivityCard(
          activity: activity,
          onUpdateStatus: updateActivityStatus,
        );
      },
    );
  }

  Widget _buildPreviousActivitiesTab() {
    final previousActivities = activities.where((activity) => activity.status != 'pending').toList();

    return previousActivities.isEmpty
        ? Center(child: Text('No previous activities for this crop'))
        : ListView.builder(
      itemCount: previousActivities.length,
      itemBuilder: (context, index) {
        final activity = previousActivities[index];
        return CropActivityCard(
          activity: activity,
          onUpdateStatus: updateActivityStatus,
        );
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

  Widget _buildTasksTab() {
    return TaskListPage(cropId: widget.crop.id);
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
        length: 6,
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
