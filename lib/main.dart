import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'core/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep Android system bars visible and support edge-to-edge layout.
  // System bar colors and icon brightness are configured by the app theme.
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // Initialize the existing Essax Supabase project.
  await initializeSupabase();

  runApp(const EssaxApp());
}