import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _api = AppointmentService();
  late Future<List<Appointment>> future;

  @override
  void initState() {
    super.initState();
    future = _api.getMyAppointments();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Le mie prenotazioni')),
    body: FutureBuilder<List<Appointment>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return const Center(child: Text('Nessuna prenotazione.'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() => future = _api.getMyAppointments());
            await future;
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => AppointmentCard(appointment: list[i]),
          ),
        );
      },
    ),
  );
}
