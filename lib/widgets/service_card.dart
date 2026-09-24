import 'package:flutter/material.dart';
import '../models/service.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: const CircleAvatar(child: Icon(Icons.spa_outlined)),
      title: Text(service.name),
      subtitle: Text('${service.durationMinutes} minuti'),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}
