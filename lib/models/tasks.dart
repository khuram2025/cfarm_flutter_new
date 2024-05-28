class Task {
  final int id;
  final int cropId;
  final String title;
  final String description;
  final String recurrence;
  final int recurrenceCount;
  final String startDate;

  Task({
    required this.id,
    required this.cropId,
    required this.title,
    required this.description,
    required this.recurrence,
    required this.recurrenceCount,
    required this.startDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      cropId: json['crop'],
      title: json['title'],
      description: json['description'] ?? '',
      recurrence: json['recurrence'],
      recurrenceCount: json['recurrence_count'],
      startDate: json['start_date'],
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, cropId: $cropId, title: $title, description: $description, recurrence: $recurrence, recurrenceCount: $recurrenceCount, startDate: $startDate}';
  }
}
