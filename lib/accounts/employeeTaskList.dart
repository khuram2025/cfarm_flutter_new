// task_list_page.dart
import 'package:flutter/material.dart';

class TaskListPage extends StatelessWidget {
  final int employeeId;

  const TaskListPage({Key? key, required this.employeeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Tasks for Employee ID: $employeeId (to be implemented)'),
    );
  }
}
