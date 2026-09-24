import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/primary_button.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final email = _email.text.trim();

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci una email valida.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Il backend del progetto usa la rotta di richiesta codice.
      // Se il tuo endpoint ha un nome diverso, cambialo in AuthService.
      await _auth.requestCode(email: email);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OtpScreen(email: email)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                // Text(
                //   'AF Beauty Art',
                //   style: Theme.of(context).textTheme.headlineMedium,
                // ),
                const SizedBox(height: 8),
                const Text(
                  'Accedi per gestire le tue prenotazioni.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Continua',
                  loading: _loading,
                  onPressed: _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
