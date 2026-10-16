import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration for Essax.
///
/// Values are supplied by Codemagic using Dart compile-time variables.
/// The publishable key is intended for client-side use.
/// Never use a Supabase secret or service_role key in this app.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gkheslvcojucmlywoptk.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
}

/// Initializes Supabase before the Essax application starts.
Future<void> initializeSupabase() async {
  if (urlIsInvalid(SupabaseConfig.url)) {
    throw StateError(
      'Essax Supabase URL is missing or invalid. '
      'Check SUPABASE_URL in your Codemagic configuration.',
    );
  }

  if (SupabaseConfig.publishableKey.trim().isEmpty) {
    throw StateError(
      'Essax Supabase publishable key is missing. '
      'Configure SUPABASE_PUBLISHABLE_KEY in Codemagic and pass it '
      'to Flutter using --dart-define.',
    );
  }

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );

    debugPrint('Essax: Supabase initialized successfully.');
  } catch (error, stackTrace) {
    debugPrint('Essax: Supabase initialization failed.');

    // Detailed diagnostics are restricted to debug builds.
    if (kDebugMode) {
      debugPrint('$error');
      debugPrintStack(stackTrace: stackTrace);
    }

    rethrow;
  }
}

/// Basic validation to catch accidental URL misconfiguration.
bool urlIsInvalid(String url) {
  final uri = Uri.tryParse(url);

  return uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty;
}

/// Shared Supabase client for Essax services and repositories.
SupabaseClient get supabase => Supabase.instance.client;