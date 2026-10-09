
import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../services/auth_service.dart';
import '../../services/device_token_service.dart';
import '../../services/theme_controller.dart';
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
    await DeviceTokenService.unregisterCurrentDevice();
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _chooseTheme() {
    final current = Theme.of(context).brightness;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Aspetto',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 10),
              _ThemeChoice(
                icon: Icons.brightness_auto_outlined,
                title: 'Automatico',
                selected: false,
                onTap: () {
                  ThemeController.set(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              _ThemeChoice(
                icon: Icons.light_mode_outlined,
                title: 'Chiaro',
                selected: current == Brightness.light,
                onTap: () {
                  ThemeController.set(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              _ThemeChoice(
                icon: Icons.dark_mode_outlined,
                title: 'Scuro',
                selected: current == Brightness.dark,
                onTap: () {
                  ThemeController.set(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profilo')),
    body: FutureBuilder<Customer>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return const Center(child: CircularProgressIndicator());
        }

        final c = snapshot.data!;
        final scheme = Theme.of(context).colorScheme;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withOpacity(.18),
                    scheme.primary.withOpacity(.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    child: Text(
                      c.firstName.isEmpty ? '?' : c.firstName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    c.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(c.email),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'I tuoi dati'),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  _ProfileRow(
                    icon: Icons.person_outline,
                    title: 'Nome',
                    value: c.fullName,
                  ),
                  _ProfileRow(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: c.email,
                  ),
                  _ProfileRow(
                    icon: Icons.phone_outlined,
                    title: 'Telefono',
                    value: c.phone.isEmpty ? 'Non inserito' : c.phone,
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Preferenze'),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                title: const Text('Aspetto'),
                subtitle: const Text('Chiaro, scuro o automatico'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _chooseTheme,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Esci'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
    ),
  );
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool last;

  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.value,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(title, style: const TextStyle(fontSize: 12)),
    subtitle: Text(
      value,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
  );
}

class _ThemeChoice extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: selected ? const Icon(Icons.check_circle) : null,
    onTap: onTap,
  );
}
