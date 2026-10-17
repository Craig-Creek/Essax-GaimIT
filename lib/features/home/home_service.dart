import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';

class HomeService {
  HomeService._();

  static final SupabaseClient _client = supabase;

  static Future<List<Map<String, dynamic>>>
      getUpcomingCompetitions() async {
    final now = DateTime.now().toUtc().toIso8601String();

    final response = await _client
        .from('competitions')
        .select(
          'id, title, description, image_url, '
          'starts_at, ends_at, status',
        )
        .eq('status', 'published')
        .gte('starts_at', now)
        .order('starts_at', ascending: true)
        .limit(5);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>>
      getRecentDiscussions() async {
    final response = await _client
        .from('discussions')
        .select(
          'id, title, body, category, author_id, created_at',
        )
        .eq('status', 'published')
        .order('created_at', ascending: false)
        .limit(5);

    return List<Map<String, dynamic>>.from(response);
  }
}