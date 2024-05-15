import 'package:flutter/material.dart';



class ExpensePageModel {
  void dispose() {}
}

class ExpensePageWidget extends StatefulWidget {
  const ExpensePageWidget({super.key});

  @override
  State<ExpensePageWidget> createState() => _ExpensePageWidgetState();
}

class _ExpensePageWidgetState extends State<ExpensePageWidget> {
  late ExpensePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = ExpensePageModel();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expense List',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, 'AddAnimalMobilePage');
                            },
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, 'AddAnimalMobilePage');
                              },
                              child: Text('Add Expense'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, 'SearchFilterMobilePage');
                            },
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, 'SearchFilterMobilePage');
                              },
                              child: Text('Filters'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildExpenseItem(context, 'GreenFeed', '24 April, 2024', 'Rs. 12000.00'),
              const Divider(),
              _buildExpenseItem(context, 'GreenFeed', '24 April, 2024', 'Rs. 12000.00'),
              const Divider(),
              _buildExpenseItem(context, 'GreenFeed', '24 April, 2024', 'Rs. 12000.00'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseItem(BuildContext context, String title, String date, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              Text(
                date,
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.arrow_upward,
                color: Theme.of(context).textTheme.caption?.color,
                size: 24,
              ),
              Text(
                amount,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.delete_sharp,
                color: Theme.of(context).errorColor,
                size: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
