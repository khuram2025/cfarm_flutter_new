import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'taskCreatePage.dart';
import '../models/tasks.dart';
import '../widgets/TaskCard.dart';

const String baseUrl = 'http://farmapp.channab.com';

class TaskListPage extends StatefulWidget {
  final int cropId;

  const TaskListPage({Key? key, required this.cropId}) : super(key: key);

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/crops/api/crops/${widget.cropId}/tasks/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> tasksJson = json.decode(response.body);
      print('Parsed JSON: $tasksJson');
      setState(() {
        tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
        print('Tasks: $tasks');
      });
    } else {
      print('Failed to load tasks with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> updateTaskStatus(int instanceId, String status) async {
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
      print('Task status updated successfully');
    } else {
      print('Failed to update task status with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _navigateToCreateTaskPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskPage(cropId: widget.cropId),
      ),
    );
    if (result == true) {
      fetchTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToCreateTaskPage,
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(child: Text('No tasks available'))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onUpdateStatus: updateTaskStatus,
          );
        },
      ),
    );
  }
}

