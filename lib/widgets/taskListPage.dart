import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String baseUrl = 'http://192.168.8.153';

class TaskListPage extends StatefulWidget {
  final int cropId;

  const TaskListPage({Key? key, required this.cropId}) : super(key: key);

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/crops/api/${widget.cropId}/tasks/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> taskDataJson = json.decode(response.body)['task_data'];
      setState(() {
        tasks = taskDataJson.map((json) => Task.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      print('Failed to load tasks with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateTaskInstanceStatus(int instanceId, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.patch(
      Uri.parse('$baseUrl/api/instances/$instanceId/status/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      fetchTasks();
    } else {
      print('Failed to update task instance status with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  String formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return DateFormat('EEEE, MMMM d').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? Center(child: Text('No tasks available'))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: ExpansionTile(
              leading: Icon(Icons.task, color: Color(0xFF0DA487)),
              title: Text(
                '${task.title} (${task.upcomingInstances.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0DA487),
                ),
              ),
              subtitle: Text(
                'Next Task: ${task.nextActivityDate.isNotEmpty ? formatDate(task.nextActivityDate) : 'N/A'}',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Upcoming Instances:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...task.upcomingInstances.map((instance) => ListTile(
                        title: Text('${formatDate(instance.scheduledDate)} - Status: ${instance.status}'),
                        trailing: instance.status == 'pending'
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () => updateTaskInstanceStatus(instance.id, 'completed'),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => updateTaskInstanceStatus(instance.id, 'canceled'),
                            ),
                          ],
                        )
                            : null,
                      )),
                      SizedBox(height: 10),
                      Text('Previous Instances:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...task.previousInstances.map((instance) => ListTile(
                        title: Text(
                          '${formatDate(instance.scheduledDate)} - Status: ${instance.status}',
                          style: TextStyle(
                            color: instance.status == 'unattended'
                                ? Color(0XEF5315FF)
                                : Color(0xFF0DA487),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Task {
  final int id;
  final String title;
  final String description;
  final String recurrence;
  final int recurrenceCount;
  final String startDate;
  final List<TaskInstance> upcomingInstances;
  final List<TaskInstance> previousInstances;
  final String nextActivityDate;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.recurrence,
    required this.recurrenceCount,
    required this.startDate,
    required this.upcomingInstances,
    required this.previousInstances,
    required this.nextActivityDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['task']['id'],
      title: json['task']['title'],
      description: json['task']['description'],
      recurrence: json['task']['recurrence'],
      recurrenceCount: json['task']['recurrence_count'],
      startDate: json['task']['start_date'],
      upcomingInstances: (json['upcoming_instances'] as List)
          .map((data) => TaskInstance.fromJson(data))
          .toList(),
      previousInstances: (json['previous_instances'] as List)
          .map((data) => TaskInstance.fromJson(data))
          .toList(),
      nextActivityDate: json['upcoming_instances'].isNotEmpty
          ? json['upcoming_instances'][0]['scheduled_date']
          : '',
    );
  }
}

class TaskInstance {
  final int id;
  final String scheduledDate;
  final String status;

  TaskInstance({
    required this.id,
    required this.scheduledDate,
    required this.status,
  });

  factory TaskInstance.fromJson(Map<String, dynamic> json) {
    return TaskInstance(
      id: json['id'],
      scheduledDate: json['scheduled_date'],
      status: json['status'],
    );
  }
}
