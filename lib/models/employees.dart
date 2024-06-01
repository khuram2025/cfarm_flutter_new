// lib/models/employees.dart
class Employee {
  final int id;
  final String firstName;
  final String lastName;
  final String mobile;
  final String email;
  final String? imageUrl;
  final String? role;
  final String? joiningDate;
  final String? endDate;
  final String? status;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.email,
    this.imageUrl,
    this.role,
    this.joiningDate,
    this.endDate,
    this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['employee_id'] ?? 0,  // Use employee_id from JSON
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['image_url'],
      role: json['role'],
      joiningDate: json['joining_date'],
      endDate: json['end_date'],
      status: json['status'],
    );
  }
}
