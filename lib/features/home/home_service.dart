import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';

class HomeService {
  static final SupabaseClient _client = supabase;

  static Future<List<Map<String, dynamic>>> getCompetitions() async {
    final response = await _client
        .from('competitions')
        .select('id, title, description')
        .eq('status', 'published')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getDiscussions() async {
    final response = await _client
        .from('discussions')
        .select('id, title, body, category')
        .eq('status', 'published')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getTeams() async {
    final response = await _client
        .from('teams')
        .select('id, name, description')
        .eq('is_public', true)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>> getHomeData() async {
    final results = await Future.wait([
      getCompetitions(),
      getDiscussions(),
      getTeams(),
    ]);

    return {
      'competitions': results[0],
      'discussions': results[1],
      'teams': results[2],
    };
  }
}