import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../apis/models.dart';
import 'widgets/animal_overview_table.dart';

const String baseUrl = 'http://farmapp.channab.com';

class AnimalDetailPage extends StatefulWidget {
  final Animal animal;

  const AnimalDetailPage({Key? key, required this.animal}) : super(key: key);

  @override
  _AnimalDetailPageState createState() => _AnimalDetailPageState();
}

class _AnimalDetailPageState extends State<AnimalDetailPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> _buildTabs() {
    return [
      Tab(text: 'Overview'),
      Tab(text: 'Weight'),
      Tab(text: 'Family'),
      Tab(text: 'Milk'),
      Tab(text: 'Health'),
      Tab(text: 'Gallery'),
    ];
  }

  List<Widget> _buildTabViews() {
    return [
      _buildOverviewTab(),
      _buildWeightTab(),
      _buildFamilyTab(),
      _buildMilkTab(),
      _buildHealthTab(),
      _buildGalleryTab(),
    ];
  }

  Widget _buildOverviewTab() {
    return AnimalOverviewTable(
      tag: widget.animal.tag,
      age: _calculateAge(widget.animal.dob),
      type: widget.animal.animalType,
      status: widget.animal.status,
      gender: widget.animal.sex,
      price: widget.animal.purchaseCost != null ? '\$${widget.animal.purchaseCost}' : 'N/A',
    );
  }

  String _calculateAge(DateTime dob) {
    final now = DateTime.now();
    final age = now.year - dob.year;
    return '$age years';
  }

  Widget _buildWeightTab() {
    return Center(
      child: Text('Weight Records for Animal: ${widget.animal.tag}'),
    );
  }

  Widget _buildFamilyTab() {
    return Center(
      child: Text('Family Information for Animal: ${widget.animal.tag}'),
    );
  }

  Widget _buildMilkTab() {
    return Center(
      child: Text('Milk Records for Animal: ${widget.animal.tag}'),
    );
  }

  Widget _buildHealthTab() {
    return Center(
      child: Text('Health Records for Animal: ${widget.animal.tag}'),
    );
  }

  Widget _buildGalleryTab() {
    return Center(
      child: Text('Gallery for Animal: ${widget.animal.tag}'),
    );
  }

  Future<void> _deleteAnimal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.delete(
      Uri.parse('$baseUrl/api/animals/${widget.animal.id}/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 204) {
      Navigator.pop(context, true); // Indicate that the animal was deleted
    } else {
      print('Failed to delete animal with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _editAnimal() {
    // Navigate to the edit animal page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    widget.animal.imagePath != null
                        ? Image.network(
                      widget.animal.imagePath!,
                      fit: BoxFit.fill,
                    )
                        : Container(
                      color: Colors.grey,
                      child: Icon(Icons.image_not_supported),
                    ),
                    Positioned(
                      top: 30.0,
                      left: 10.0,
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
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
                      widget.animal.tag,
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
                        onPressed: _editAnimal,
                        color: Color(0xFF0DA487),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever_rounded),
                        onPressed: _deleteAnimal,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabs: _buildTabs(),
                      labelColor: Colors.white,
                      unselectedLabelColor: Color(0xFF0DA487),
                      indicator: BoxDecoration(
                        color: Color(0xFF0DA487),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      indicatorPadding: EdgeInsets.zero,
                      indicatorSize: TabBarIndicatorSize.tab,
                    ),
                  ),
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
