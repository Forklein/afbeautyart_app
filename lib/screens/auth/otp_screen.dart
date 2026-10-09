
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/device_token_service.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/primary_button.dart';
import '../home/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _code = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_code.text.trim().isEmpty) return;

    setState(() => _loading = true);

    try {
      final result = await _auth.verifyCode(
        email: widget.email,
        code: _code.text.trim(),
      );

      if (result.token == null || result.token!.isEmpty) {
        throw Exception('Il server non ha restituito il token.');
      }

      // Da questo momento il JWT identifica il customer: possiamo associare
      // in modo sicuro il token FCM al customer sul backend.
      await DeviceTokenService.registerCurrentDevice();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (_) => false,
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
    appBar: AppBar(title: const Text('Verifica')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const AppLogo(width: 100),
                const SizedBox(height: 26),
                Text(
                  'Inserisci il codice',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Abbiamo inviato un codice a ${widget.email}.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                  ),
                  decoration: const InputDecoration(
                    hintText: '000000',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Accedi',
                  loading: _loading,
                  onPressed: _verify,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
