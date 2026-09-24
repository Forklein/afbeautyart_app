class Employee {
  final int id;
  final String firstName;
  final String lastName;

  const Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: (json['id'] as num?)?.toInt() ?? 0,
    firstName: json['first_name']?.toString() ?? '',
    lastName: json['last_name']?.toString() ?? '',
  );

  String get fullName => '$firstName $lastName'.trim();
}
