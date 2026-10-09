
import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final status = _statusStyle(appointment);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(.11),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.spa_outlined, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appointment.service.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withOpacity(.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 19, color: scheme.primary),
                  const SizedBox(width: 9),
                  Text(
                    '${appointment.date}  •  ${appointment.time}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.providerName.isEmpty
                        ? 'Operatrice non disponibile'
                        : appointment.providerName,
                  ),
                ),
              ],
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: color.withOpacity(.10),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}
