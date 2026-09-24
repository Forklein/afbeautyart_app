class Service {
  final int id;
  final String name;
  final int durationSeconds;
  final int durationMinutes;
  final double price;

  const Service({
    required this.id,
    required this.name,
    required this.durationSeconds,
    required this.durationMinutes,
    required this.price,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name']?.toString() ?? '',
    durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
    durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
    price: (json['price'] as num?)?.toDouble() ?? 0,
  );
}
