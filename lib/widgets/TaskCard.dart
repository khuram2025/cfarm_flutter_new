import 'package:flutter/material.dart';
import '../models/tasks.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Future<void> Function(int, String) onUpdateStatus;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onUpdateStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(task.description),
            SizedBox(height: 8),
            Text('Recurrence: ${task.recurrence}'),
            Text('Recurrence Count: ${task.recurrenceCount}'),
            Text('Start Date: ${task.startDate}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () {
                    onUpdateStatus(task.id, 'completed');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () {
                    onUpdateStatus(task.id, 'canceled');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
