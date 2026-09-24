import 'package:flutter/material.dart';
import '../../models/service.dart';
import '../../services/api_service.dart';
import '../../widgets/service_card.dart';
import '../booking/booking_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _api = ApiService();
  late Future<List<Service>> future;

  @override
  void initState() {
    super.initState();
    future = _api.getServices();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Servizi')),
    body: FutureBuilder<List<Service>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final services = snapshot.data ?? [];
        return RefreshIndicator(
          onRefresh: () async {
            setState(() => future = _api.getServices());
            await future;
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => ServiceCard(
              service: services[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingScreen(service: services[i]),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
