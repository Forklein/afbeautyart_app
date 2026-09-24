import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/push_notification_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Non blocca l'avvio dell'app se Firebase non è ancora configurato.
  await PushNotificationService.initialize(appNavigatorKey);

  runApp(const AfBeautyArtApp());
}

class AfBeautyArtApp extends StatelessWidget {
  const AfBeautyArtApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: appNavigatorKey,
    title: 'AF Beauty Art',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const AppBootstrap(),
  );
}

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: StorageService.hasToken(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return snapshot.data == true
          ? const HomeScreen()
          : const LoginScreen();
    },
  );
}
