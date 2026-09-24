class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: (json['id'] as num?)?.toInt() ?? 0,
    firstName: json['first_name']?.toString() ?? '',
    lastName: json['last_name']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
  );

  String get fullName => '$firstName $lastName'.trim();
}
