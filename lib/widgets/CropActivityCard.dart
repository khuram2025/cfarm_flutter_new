import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class CropActivity {
  final int id;
  final String title;
  final String description;
  final String date;
  final String recurrence;
  final String status;

  CropActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.recurrence,
    required this.status,
  });

  factory CropActivity.fromJson(Map<String, dynamic> json) {
    return CropActivity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      recurrence: json['recurrence'],
      status: json['status'],
    );
  }

  DateTime get activityDate => DateTime.parse(date);

  List<DateTime> getNextOccurrences(int count) {
    List<DateTime> occurrences = [];
    DateTime nextDate = activityDate;
    for (int i = 0; i < count; i++) {
      occurrences.add(nextDate);
      switch (recurrence) {
        case 'daily':
          nextDate = nextDate.add(Duration(days: 1));
          break;
        case 'weekly':
          nextDate = nextDate.add(Duration(days: 7));
          break;
        case 'monthly':
          nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
          break;
        case 'single':
        default:
          return occurrences;
      }
    }
    return occurrences;
  }
}

class CropActivityCard extends StatefulWidget {
  final CropActivity activity;
  final Future<void> Function(int, String) onUpdateStatus;

  const CropActivityCard({Key? key, required this.activity, required this.onUpdateStatus}) : super(key: key);

  @override
  _CropActivityCardState createState() => _CropActivityCardState();
}

class _CropActivityCardState extends State<CropActivityCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    List<DateTime> occurrences = widget.activity.getNextOccurrences(5);

    return InkWell(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < (isExpanded ? occurrences.length : 1); i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.activity.recurrence,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                DateFormat('EEEE, d MMMM').format(occurrences[i]),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: FaIcon(FontAwesomeIcons.edit, size: 16),
                                onPressed: () {
                                  // Handle edit action
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_forever_rounded, size: 16),
                                onPressed: () {
                                  // Handle delete action
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        widget.activity.title,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.activity.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getRemainingTime(occurrences[i]),
                            style: TextStyle(color: Colors.red),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.check_circle, color: Colors.green, size: 24),
                                onPressed: () {
                                  widget.onUpdateStatus(widget.activity.id, 'completed');
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red, size: 24),
                                onPressed: () {
                                  widget.onUpdateStatus(widget.activity.id, 'canceled');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRemainingTime(DateTime activityDate) {
    final now = DateTime.now();
    final difference = activityDate.difference(now);
    if (difference.isNegative) {
      return 'Past Activity';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else {
      return '${difference.inDays} days left';
    }
  }

  void _showActivityDetails(BuildContext context, CropActivity activity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(activity.title),
          content: Text(activity.description),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
