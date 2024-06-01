// employee_add.dart
import 'package:flutter/material.dart';

class AddEmployeePage extends StatelessWidget {
  final int? employeeId;

  const AddEmployeePage({Key? key, this.employeeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(employeeId == null ? 'Add Employee' : 'Edit Employee'),
      ),
      body: Center(
        child: Text('Form to add/edit employee (to be implemented)'),
      ),
    );
  }
}

