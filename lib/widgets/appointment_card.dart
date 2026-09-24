import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final status = _statusStyle(appointment);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: status.color,
              width: 5,
            ),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    appointment.service.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: status.label,
                  color: status.color,
                  icon: status.icon,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              text: '${appointment.date} • ${appointment.time}',
            ),
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.person_outline,
              text: appointment.providerName.isEmpty
                  ? 'Operatrice non disponibile'
                  : 'Operatrice: ${appointment.providerName}',
            ),
          ],
        ),
      ),
    );
  }

  _AppointmentStatus _statusStyle(Appointment appointment) {
    final status = appointment.status.trim().toLowerCase();
    final appointmentStatus = appointment.appointmentStatus.trim().toLowerCase();
    final effectiveStatus = status.isNotEmpty ? status : appointmentStatus;

    if (effectiveStatus == 'canceled' ||
        effectiveStatus == 'cancelled' ||
        effectiveStatus == 'rejected') {
      return _AppointmentStatus(
        label: effectiveStatus == 'rejected' ? 'Rifiutata' : 'Cancellata',
        color: Colors.red,
        icon: Icons.close,
      );
    }

    if (effectiveStatus == 'approved' ||
        effectiveStatus == 'confirmed' ||
        effectiveStatus == 'accepted') {
      return const _AppointmentStatus(
        label: 'Confermata',
        color: Colors.green,
        icon: Icons.check,
      );
    }

    return const _AppointmentStatus(
      label: 'In attesa',
      color: Colors.orange,
      icon: Icons.schedule,
    );
  }
}

class _AppointmentStatus {
  final String label;
  final Color color;
  final IconData icon;

  const _AppointmentStatus({
    required this.label,
    required this.color,
    required this.icon,
  });
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
      const SizedBox(width: 8),
      Expanded(child: Text(text)),
    ],
  );
}
