import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';

class TeamsService {
  TeamsService._();

  static SupabaseClient get _db => supabase;

  static String? get currentUserId => _db.auth.currentUser?.id;

  static Future<List<Map<String, dynamic>>> getTeams() async {
    final response = await _db
        .from('teams')
        .select('id, name, description, avatar_url, owner_id, is_public, created_at')
        .eq('is_public', true)
        .order('created_at', ascending: false);

    final teams = List<Map<String, dynamic>>.from(response);

    for (final team in teams) {
      try {
        final memberships = await _db
            .from('team_memberships')
            .select('user_id')
            .eq('team_id', team['id'])
            .eq('status', 'active');

        team['member_count'] = memberships.length;
      } catch (_) {
        team['member_count'] = 0;
      }
    }

    return teams;
  }

  static Future<Map<String, dynamic>> getTeamDetails(
    String teamId,
  ) async {
    final team = await _db
        .from('teams')
        .select()
        .eq('id', teamId)
        .maybeSingle();

    if (team == null) {
      throw Exception('This team could not be found.');
    }

    final memberships = await _db
        .from('team_memberships')
        .select('user_id, role, status, created_at')
        .eq('team_id', teamId)
        .eq('status', 'active');

    return {
      ...team,
      'members': List<Map<String, dynamic>>.from(memberships),
      'member_count': memberships.length,
    };
  }

  static Future<void> createTeam({
    required String name,
    required String description,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('Please sign in before creating a team.');
    }

    final cleanName = name.trim();
    final cleanDescription = description.trim();

    if (cleanName.length < 2 || cleanName.length > 100) {
      throw Exception('Team name must contain 2–100 characters.');
    }

    await _db.from('teams').insert({
      'owner_id': userId,
      'name': cleanName,
      'description': cleanDescription,
      'is_public': true,
    });
  }

  static Future<void> requestToJoin(String teamId) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('Please sign in to request membership.');
    }

    final existing = await _db
        .from('team_memberships')
        .select('status')
        .eq('team_id', teamId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      final status = existing['status'];

      if (status == 'active') {
        throw Exception('You are already a member of this team.');
      }

      if (status == 'pending') {
        throw Exception('Your request is already pending.');
      }

      await _db
          .from('team_memberships')
          .update({
            'role': 'member',
            'status': 'pending',
          })
          .eq('team_id', teamId)
          .eq('user_id', userId);

      return;
    }

    await _db.from('team_memberships').insert({
      'team_id': teamId,
      'user_id': userId,
      'role': 'member',
      'status': 'pending',
    });
  }

  static Future<List<Map<String, dynamic>>> getJoinRequests(
    String teamId,
  ) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('Please sign in first.');
    }

    final team = await _db
        .from('teams')
        .select('owner_id')
        .eq('id', teamId)
        .single();

    if (team['owner_id'] != userId) {
      throw Exception('Only the team owner can review requests.');
    }

    final response = await _db
        .from('team_memberships')
        .select('team_id, user_id, role, status, created_at')
        .eq('team_id', teamId)
        .eq('status', 'pending')
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> approveRequest({
    required String teamId,
    required String userId,
  }) async {
    await _db
        .from('team_memberships')
        .update({'status': 'active'})
        .eq('team_id', teamId)
        .eq('user_id', userId)
        .eq('status', 'pending');
  }

  static Future<void> rejectRequest({
    required String teamId,
    required String userId,
  }) async {
    await _db
        .from('team_memberships')
        .delete()
        .eq('team_id', teamId)
        .eq('user_id', userId)
        .eq('status', 'pending');
  }

  static Future<String?> getMembershipStatus(String teamId) async {
    final userId = currentUserId;

    if (userId == null) return null;

    final response = await _db
        .from('team_memberships')
        .select('status')
        .eq('team_id', teamId)
        .eq('user_id', userId)
        .maybeSingle();

    return response?['status']?.toString();
  }
}