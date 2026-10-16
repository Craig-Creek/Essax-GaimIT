import '../../core/supabase_client.dart';

/// Handles Supabase data operations for the Essax Home screen.
///
/// Keep database queries here instead of putting them directly
/// inside HomeScreen widgets.
class HomeService {
  HomeService();

  /// Confirms that the Supabase client can reach the backend.
  ///
  /// This checks the Auth endpoint. It does not yet verify access
  /// to the Essax application tables.
  Future<bool> checkConnection() async {
    await supabase.auth.getSession();
    return true;
  }
}