import 'package:flutter/material.dart';

class AmountEntryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          tabs: [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
            Tab(text: 'Transfer'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Icon(Icons.add),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'INR',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.camera_alt),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Date of spend',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Payment Mode',
                border: OutlineInputBorder(),
              ),
              items: ['Cash', 'Card', 'Online']
                  .map((mode) => DropdownMenuItem(
                child: Text(mode),
                value: mode,
              ))
                  .toList(),
              onChanged: (value) {},
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Category',
                border: OutlineInputBorder(),
              ),
              items: ['Education', 'Groceries', 'Transport']
                  .map((category) => DropdownMenuItem(
                child: Text(category),
                value: category,
              ))
                  .toList(),
              onChanged: (value) {},
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Checkbox(value: false, onChanged: (value) {}),
                Text('Possible Duplicated Detected'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
