import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_shell.dart';

class EssaxApp extends StatelessWidget {
  const EssaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Essax',
      debugShowCheckedModeBanner: false,

      // Follow the Android system's light/dark appearance by default.
      themeMode: ThemeMode.system,

      // Centralized application themes.
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Main application layout and navigation.
      home: const AppShell(),
    );
  }
}