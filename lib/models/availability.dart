class Availability {
  final String date;
  final String time;

  const Availability({required this.date, required this.time});

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      date: json['date']?.toString() ?? '',
      time: (json['time'] ?? json['start'] ?? json['bookingStart'])?.toString() ?? '',
    );
  }
}
