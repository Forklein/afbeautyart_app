import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
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

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
    appBar: AppBar(title: const Text('Verifica codice')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Codice inviato a ${widget.email}'),
          const SizedBox(height: 20),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(labelText: 'Codice OTP'),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Verifica',
            loading: _loading,
            onPressed: _verify,
          ),
        ],
      ),
    ),
  );
}
