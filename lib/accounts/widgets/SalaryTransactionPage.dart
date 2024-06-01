import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/salary_transaction.dart';
import '../../Finance/addSalaryTransaction.dart';

class SalaryTransactionPage extends StatefulWidget {
  final int employeeId;

  const SalaryTransactionPage({Key? key, required this.employeeId}) : super(key: key);

  @override
  _SalaryTransactionPageState createState() => _SalaryTransactionPageState();
}

class _SalaryTransactionPageState extends State<SalaryTransactionPage> {
  Future<Map<String, dynamic>>? transactionsFuture;
  final Map<String, Color> _componentColors = {};
  final List<Color> _availableColors = [
    Color(0xFF0DA487),
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.red,
    Colors.brown,
    Colors.cyan,
  ];
  int _colorIndex = 0;
  bool sortAscending = true;
  int? sortColumnIndex;

  @override
  void initState() {
    super.initState();
    transactionsFuture = fetchSalaryTransactions();
  }

  Future<Map<String, dynamic>> fetchSalaryTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('http://farmapp.channab.com/accounts/api/employees/${widget.employeeId}/salary_transactions/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return {
        'transactions': (responseData['transactions'] as List).map((data) => SalaryTransaction.fromJson(data)).toList(),
        'salary_status': Map<String, dynamic>.from(responseData['salary_status']),
      };
    } else {
      throw Exception('Failed to load salary transactions');
    }
  }

  Color _getComponentColor(String component) {
    if (!_componentColors.containsKey(component)) {
      _componentColors[component] = _availableColors[_colorIndex % _availableColors.length];
      _colorIndex++;
    }
    return _componentColors[component]!;
  }

  void _sort<T>(Comparable<T> Function(SalaryTransaction transaction) getField, int columnIndex, bool ascending) {
    setState(() {
      transactionsFuture = transactionsFuture!.then((data) {
        final transactions = data['transactions'] as List<SalaryTransaction>;
        transactions.sort((a, b) {
          if (!ascending) {
            final SalaryTransaction c = a;
            a = b;
            b = c;
          }
          final aValue = getField(a);
          final bValue = getField(b);
          return Comparable.compare(aValue, bValue);
        });
        return data;
      });
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
    });
  }

  void _editTransaction(SalaryTransaction transaction) async {
    // Navigate to AddSalaryTransactionScreen with transaction data
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSalaryTransactionScreen(
          initialEmployeeId: widget.employeeId,
          transaction: transaction,
        ),
      ),
    );
    // Refresh transactions after editing
    setState(() {
      transactionsFuture = fetchSalaryTransactions();
    });
  }

  void _deleteTransaction(int transactionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.delete(
      Uri.parse('http://farmapp.channab.com/accounts/api/delete-salary-transaction/$transactionId/'),
      headers: {
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaction deleted successfully')));
      setState(() {
        transactionsFuture = fetchSalaryTransactions();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete transaction')));
    }
  }

  void _showTransactionDetails(SalaryTransaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Transaction Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Date: ${transaction.transactionDate}'),
                Text('Amount: ${transaction.amountPaid}'),
                Text('Component: ${transaction.componentName}'),
                Text('Description: ${transaction.description ?? 'N/A'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Edit'),
              onPressed: () {
                Navigator.of(context).pop();
                _editTransaction(transaction);
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTransaction(transaction.id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load transactions: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!['transactions'].isEmpty) {
            return Center(child: Text('No transactions found.'));
          } else {
            final transactions = snapshot.data!['transactions'] as List<SalaryTransaction>;
            final salaryStatus = snapshot.data!['salary_status'];

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        sortAscending: sortAscending,
                        sortColumnIndex: sortColumnIndex,
                        columnSpacing: 10.0,
                        columns: [
                          DataColumn(
                            label: Text('Date'),
                            onSort: (columnIndex, ascending) {
                              _sort<String>((transaction) => transaction.transactionDate, columnIndex, ascending);
                            },
                          ),
                          DataColumn(
                            label: Text('Amount'),
                            numeric: true,
                            onSort: (columnIndex, ascending) {
                              _sort<num>((transaction) => transaction.amountPaid, columnIndex, ascending);
                            },
                          ),
                          DataColumn(label: Text('Component')),
                          DataColumn(label: Text('Details')),
                        ],
                        rows: transactions.map((transaction) {
                          return DataRow(cells: [
                            DataCell(Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(DateFormat('d MMM, yyyy').format(DateTime.parse(transaction.transactionDate))),
                            )),
                            DataCell(Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text('Rs. ${transaction.amountPaid}'),
                            )),
                            DataCell(Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getComponentColor(transaction.componentName).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                transaction.componentName,
                                style: TextStyle(color: _getComponentColor(transaction.componentName), fontWeight: FontWeight.bold),
                              ),
                            )),
                            DataCell(TextButton(
                              onPressed: () => _showTransactionDetails(transaction),
                              child: Text(
                                'Details',
                                style: TextStyle(color: Color(0xFF0DA487)),
                              ),
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
