import 'package:flutter/material.dart';
import '../../models/availability.dart';
import '../../models/employee.dart';
import '../../models/service.dart';
import '../../services/api_service.dart';
import '../../services/appointment_service.dart';
import '../../widgets/employee_card.dart';
import '../../widgets/primary_button.dart';

class BookingScreen extends StatefulWidget {
  final Service service;
  const BookingScreen({super.key, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _api = ApiService();
  final _booking = AppointmentService();
  List<Employee> employees = [];
  Employee? employee;
  List<Availability> slots = [];
  Availability? slot;
  DateTime date = DateTime.now();
  bool loading = true;
  bool booking = false;

  String get dateString =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      employees = await _api.getEmployees();
      employee = employees.isNotEmpty ? employees.first : null;
      if (employee != null) {
        slots = await _booking.getAvailability(
          serviceId: widget.service.id,
          providerId: employee!.id,
          date: dateString,
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _reloadSlots() async {
    if (employee == null) return;
    setState(() {
      loading = true;
      slot = null;
    });
    try {
      slots = await _booking.getAvailability(
        serviceId: widget.service.id,
        providerId: employee!.id,
        date: dateString,
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: date,
    );
    if (value == null) return;
    date = value;
    await _reloadSlots();
  }

  Future<void> _create() async {
    if (employee == null || slot == null) return;
    setState(() => booking = true);
    try {
      await _booking.createAppointment(
        serviceId: widget.service.id,
        providerId: employee!.id,
        date: dateString,
        time: slot!.time,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prenotazione creata correttamente.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => booking = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.service.name)),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Operatrice', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...employees.map((e) => EmployeeCard(
                employee: e,
                selected: employee?.id == e.id,
                onTap: () async {
                  setState(() => employee = e);
                  await _reloadSlots();
                },
              )),
              const SizedBox(height: 20),
              Text('Data', style: Theme.of(context).textTheme.titleLarge),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(dateString),
              ),
              const SizedBox(height: 20),
              Text('Orari disponibili', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (slots.isEmpty)
                const Text('Nessun orario disponibile.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: slots.map((s) => ChoiceChip(
                    label: Text(s.time),
                    selected: slot?.time == s.time,
                    onSelected: (_) => setState(() => slot = s),
                  )).toList(),
                ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Prenota',
                loading: booking,
                onPressed: slot == null ? null : _create,
              ),
            ],
          ),
  );
}
