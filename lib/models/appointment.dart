import 'service.dart';

class Appointment {
  final int bookingId;
  final int appointmentId;
  final String status;
  final String appointmentStatus;
  final String date;
  final String time;
  final String bookingStart;
  final String bookingEnd;
  final int persons;
  final Service service;
  final int providerId;
  final String providerFirstName;
  final String providerLastName;

  const Appointment({
    required this.bookingId,
    required this.appointmentId,
    required this.status,
    required this.appointmentStatus,
    required this.date,
    required this.time,
    required this.bookingStart,
    required this.bookingEnd,
    required this.persons,
    required this.service,
    required this.providerId,
    required this.providerFirstName,
    required this.providerLastName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final p = (json['provider'] as Map?)?.cast<String, dynamic>() ?? {};
    return Appointment(
      bookingId: (json['booking_id'] as num?)?.toInt() ?? 0,
      appointmentId: (json['appointment_id'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      appointmentStatus: json['appointment_status']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      bookingStart: json['booking_start']?.toString() ?? '',
      bookingEnd: json['booking_end']?.toString() ?? '',
      persons: (json['persons'] as num?)?.toInt() ?? 1,
      service: Service.fromJson(
        (json['service'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      providerId: (p['id'] as num?)?.toInt() ?? 0,
      providerFirstName: p['first_name']?.toString() ?? '',
      providerLastName: p['last_name']?.toString() ?? '',
    );
  }

  String get providerName => '$providerFirstName $providerLastName'.trim();
  bool get isCanceled => status.toLowerCase() == 'canceled' || status.toLowerCase() == 'cancelled';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isApproved => status.toLowerCase() == 'approved' ||
      appointmentStatus.toLowerCase() == 'approved';
}
