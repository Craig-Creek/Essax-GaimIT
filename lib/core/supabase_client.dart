import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sqtclmkfkvuwketnmhwm.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
}

Future<void> initializeSupabase() async {
  if (SupabaseConfig.publishableKey.isEmpty) {
    throw StateError(
      'Supabase publishable key is missing. '
      'Run the app with --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_KEY',
    );
  }

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );

    debugPrint('Essax: Supabase initialized successfully.');
  } catch (error, stackTrace) {
    debugPrint('Essax: Supabase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }
}

/// Shared Supabase client for Essax services and repositories.
SupabaseClient get supabase => Supabase.instance.client;