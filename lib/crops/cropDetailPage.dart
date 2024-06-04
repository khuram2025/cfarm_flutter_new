import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled3/crops/widgets/harvestEditPage.dart';
import 'package:untitled3/crops/widgets/noteCreatePage.dart';
import 'package:untitled3/crops/widgets/noteListTab.dart';
import 'package:untitled3/crops/widgets/harvestListTab.dart';

import '../home/customDrawer.dart';
import '../models/crops.dart';
import '../models/fields.dart';
import '../widgets/taskListPage.dart';

const String baseUrl = 'http://farmapp.channab.com';

class CropDetailPage extends StatefulWidget {
  final Crop crop;

  const CropDetailPage({Key? key, required this.crop}) : super(key: key);

  @override
  _CropDetailPageState createState() => _CropDetailPageState();
}

class _CropDetailPageState extends State<CropDetailPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<int> _activeTabIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      _activeTabIndex.value = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _activeTabIndex.dispose();
    super.dispose();
  }

  void _addButtonAction(BuildContext context, int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NoteCreatePage(cropId: widget.crop.id)),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HarvestEditPage(cropId: widget.crop.id)),
      ).then((value) {
        if (value == true) {
          setState(() {
            // Refresh the harvest list
          });
        }
      });
    } else if (index == 3) {
      // Add Task action
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: DefaultTabController(
        length: 4, // Updated length to match the number of tabs
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
                      ValueListenableBuilder<int>(
                        valueListenable: _activeTabIndex,
                        builder: (context, index, _) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0DA487),
                            ),
                            onPressed: () => _addButtonAction(context, index),
                            child: Text(
                              index == 1
                                  ? 'Add Note'
                                  : index == 2
                                  ? 'Add Harvest'
                                  : index == 3
                                  ? 'Add Task'
                                  : '',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
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
      floatingActionButton: _activeTabIndex.value == 1 || _activeTabIndex.value == 2 || _activeTabIndex.value == 3
          ? FloatingActionButton(
        backgroundColor: Color(0xFF0DA487),
        child: Icon(Icons.add),
        onPressed: () => _addButtonAction(context, _activeTabIndex.value),
      )
          : null,
    );
  }

  void _editCrop() {
    // Implement the edit crop functionality
  }

  void _deleteCrop() {
    // Implement the delete crop functionality
  }

  List<Widget> _buildTabs() {
    return [
      Tab(text: 'Info'),
      Tab(text: 'Notes'),
      Tab(text: 'Harvest'),
      Tab(text: 'Tasks'),
    ];
  }

  List<Widget> _buildTabViews() {
    return [
      _buildInfoTab(),
      _buildNotesTab(),
      HarvestListPage(cropId: widget.crop.id),  // Updated to use the new HarvestListPage
      _buildTasksTab(),
    ];
  }

  Widget _buildInfoTab() {
    return Center(
      child: Text('Crop Info: ${widget.crop.name}'),
    );
  }

  Widget _buildNotesTab() {
    return NotesListPage(cropId: widget.crop.id);
  }

  Widget _buildTasksTab() {
    return TaskListPage(cropId: widget.crop.id);
  }
}
