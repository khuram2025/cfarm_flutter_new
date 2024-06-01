import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled3/accounts/widgets/employeeInfoTab.dart';
import '../home/customDrawer.dart';
import '../models/employees.dart';
import 'employeeTaskList.dart';
import 'widgets/salary_tab_page.dart';

const String baseUrl = 'http://farmapp.channab.com';

class EmployeeDetailPage extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailPage({Key? key, required this.employee}) : super(key: key);

  @override
  _EmployeeDetailPageState createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> _buildTabs() {
    return [
      Tab(text: 'Info'),
      Tab(text: 'Salary'),
      Tab(text: 'Transactions'),
      Tab(text: 'Tasks'),
    ];
  }

  List<Widget> _buildTabViews() {
    return [
      _buildInfoTab(),
      SalaryTabPage(employeeId: widget.employee.id),
      _buildTransactionsTab(),
      _buildTasksTab(),
    ];
  }

  Widget _buildInfoTab() {
    return EmployeeInfoTable(
      name: '${widget.employee.firstName} ${widget.employee.lastName}',
      mobileNumber: widget.employee.mobile,
      email: widget.employee.email,
      role: widget.employee.role ?? 'N/A',
      joiningDate: widget.employee.joiningDate ?? 'N/A',
      endDate: widget.employee.endDate ?? 'N/A',
      status: widget.employee.status ?? 'N/A',
    );
  }

  Widget _buildSalaryTab() {
    return SalaryTabPage(employeeId: widget.employee.id);
  }

  Widget _buildTransactionsTab() {
    return Center(
      child: Text('Transactions for Employee: ${widget.employee.firstName} ${widget.employee.lastName}'),
    );
  }

  Widget _buildTasksTab() {
    return TaskListPage(employeeId: widget.employee.id); // Assuming you have a TaskListPage that takes employeeId
  }

  Future<void> _deleteEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.delete(
      Uri.parse('$baseUrl/accounts/api/employees/${widget.employee.id}/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 204) {
      Navigator.pop(context, true); // Indicate that the employee was deleted
    } else {
      print('Failed to delete employee with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _editEmployee() {
    // Navigate to the edit employee page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: DefaultTabController(
        length: 4,
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
                    widget.employee.imageUrl != null
                        ? Image.network(
                      widget.employee.imageUrl!,
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
                      '${widget.employee.firstName} ${widget.employee.lastName}',
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
                        onPressed: _editEmployee,
                        color: Color(0xFF0DA487),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever_rounded),
                        onPressed: _deleteEmployee,
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
