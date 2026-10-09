
import 'package:flutter/material.dart';
import 'storage_service.dart';

class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier(ThemeMode.system);

  static Future<void> set(ThemeMode value) async {
    mode.value = value;
    await StorageService.saveThemeMode(switch (value) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    });
  }
}
