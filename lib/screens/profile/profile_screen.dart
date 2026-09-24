import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  late Future<Customer> future;

  @override
  void initState() {
    super.initState();
    future = _auth.getMe();
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profilo')),
    body: FutureBuilder<Customer>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
          return const Center(child: CircularProgressIndicator());
        }

        final c = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            CircleAvatar(
              radius: 42,
              child: Text(c.firstName.isEmpty ? '?' : c.firstName[0].toUpperCase()),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(c.fullName, style: Theme.of(context).textTheme.headlineSmall),
            ),
            Center(child: Text(c.email)),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Nome'),
              subtitle: Text(c.fullName),
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(c.email),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Telefono'),
              subtitle: Text(c.phone),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Esci'),
            ),
          ],
        );
      },
    ),
  );
}
