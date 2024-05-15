import 'package:flutter/material.dart';

import 'customBottomBar.dart';
import 'customDrawer.dart';
import 'customeAppBar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Channab',),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('This Month'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0DA487),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Last 3 Months'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0DA487),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Last Month'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0DA487),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total Income', '92110.00', Color(0xFF0DA487)),
                _buildStatCard('Total Expenses', '308250.00', Color(0xFFEE8B60)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Status', '-216140.00', Colors.grey),
                _buildStatCard('Today Milk', '0L', Colors.grey),
              ],
            ),
            SizedBox(height: 16),
            _buildIncomeExpenseSummary('Income', 'Milk Sale', 'PKR. 92110.00', Color(0xFF0DA487)),
            SizedBox(height: 16),
            _buildIncomeExpenseSummary('Expense Summary', 'Khurram PS', 'PKR. 10000.00', Color(0xFFEE8B60)),
            _buildIncomeExpenseSummary('', 'Wanda', 'PKR. 90000.00', Color(0xFFEE8B60)),
            _buildIncomeExpenseSummary('', 'Other', 'PKR. 108250.00', Color(0xFFEE8B60)),
          ],
        ),
      ),
      // bottomNavigationBar: CustomBottomNavBar(),
    );
  }
  Widget _buildStatCard(String title, String amount, Color color) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseSummary(String title, String category, String amount, Color color) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  amount,
                  style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
