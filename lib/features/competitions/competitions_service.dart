import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';

class CompetitionsService {
  CompetitionsService._();

  static final SupabaseClient _client = supabase;

  static Future<List<Map<String, dynamic>>> getCompetitions({
    String? search,
  }) async {
    var query = _client
        .from('competitions')
        .select('id, title, description, status, created_at')
        .eq('status', 'published');

    final response = await query.order(
      'created_at',
      ascending: false,
    );

    final items = List<Map<String, dynamic>>.from(response);

    if (search == null || search.trim().isEmpty) {
      return items;
    }

    final term = search.trim().toLowerCase();

    return items.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      final description =
          (item['description'] ?? '').toString().toLowerCase();

      return title.contains(term) || description.contains(term);
    }).toList();
  }

  static Future<Map<String, dynamic>> getCompetitionById(
    Object id,
  ) async {
    final response = await _client
        .from('competitions')
        .select('id, title, description, status, created_at')
        .eq('id', id)
        .eq('status', 'published')
        .maybeSingle();

    if (response == null) {
      throw Exception('This competition is no longer available.');
    }

    return Map<String, dynamic>.from(response);
  }

  static Future<void> joinCompetition(Object competitionId) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in to join a competition.');
    }

    // Joining is intentionally not implemented until the actual
    // competition-participants table and its required columns
    // have been verified in Supabase.
    throw UnimplementedError(
      'Competition registration needs the participant table schema.',
    );
  }
}