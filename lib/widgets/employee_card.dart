import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool selected;
  final VoidCallback? onTap;

  const EmployeeCard({
    super.key,
    required this.employee,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        child: Text(employee.firstName.isEmpty ? '?' : employee.firstName[0]),
      ),
      title: Text(employee.fullName),
      trailing: selected ? const Icon(Icons.check_circle) : null,
    ),
  );
}
