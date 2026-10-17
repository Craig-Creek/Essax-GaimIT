import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';

class CommunityService {
  CommunityService._();

  static SupabaseClient get _db => supabase;

  static String? get currentUserId => _db.auth.currentUser?.id;

  static Future<List<Map<String, dynamic>>> getPosts({
    String filter = 'For You',
    String query = '',
  }) async {
    var request = _db
        .from('discussions')
        .select();

    if (filter == 'Questions') {
      request = request.eq('category', 'Questions');
    }

    if (filter == 'Trending') {
      request = request.gte(
        'created_at',
        DateTime.now()
            .subtract(const Duration(days: 7))
            .toUtc()
            .toIso8601String(),
      );
    }

    final response = await request
        .eq('status', 'published')
        .order('created_at', ascending: false)
        .limit(50);

    var posts = List<Map<String, dynamic>>.from(response);

    final search = query.trim().toLowerCase();

    if (search.isNotEmpty) {
      posts = posts.where((post) {
        final title = (post['title'] ?? '').toString().toLowerCase();
        final content = (post['content'] ?? '').toString().toLowerCase();
        final category =
            (post['category'] ?? '').toString().toLowerCase();

        return title.contains(search) ||
            content.contains(search) ||
            category.contains(search);
      }).toList();
    }

    for (final post in posts) {
      final postId = post['id'].toString();

      try {
        final likes = await _db
            .from('discussion_likes')
            .select('user_id')
            .eq('discussion_id', postId);

        final rows = List<Map<String, dynamic>>.from(likes);

        post['like_count'] = rows.length;
        post['is_liked'] = currentUserId != null &&
            rows.any((row) => row['user_id'] == currentUserId);
      } catch (_) {
        post['like_count'] = 0;
        post['is_liked'] = false;
      }

      try {
        final comments = await _db
            .from('discussion_comments')
            .select('id')
            .eq('discussion_id', postId);

        post['comment_count'] = comments.length;
      } catch (_) {
        post['comment_count'] = 0;
      }
    }

    if (filter == 'Trending') {
      posts.sort((a, b) =>
          (b['like_count'] as int).compareTo(a['like_count'] as int));
    }

    return posts;
  }

  static Future<void> createPost({
    required String title,
    required String content,
    required String category,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('Sign in to start a discussion.');
    }

    final cleanTitle = title.trim();
    final cleanContent = content.trim();

    if (cleanTitle.isEmpty || cleanContent.isEmpty) {
      throw Exception('Add a title and message before publishing.');
    }

    await _db.from('discussions').insert({
      'user_id': userId,
      'title': cleanTitle,
      'content': cleanContent,
      'category': category,
      'status': 'published',
    });
  }

  static Future<void> toggleLike({
    required String discussionId,
    required bool currentlyLiked,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('Sign in to like a discussion.');
    }

    if (currentlyLiked) {
      await _db
          .from('discussion_likes')
          .delete()
          .eq('discussion_id', discussionId)
          .eq('user_id', userId);
    } else {
      await _db.from('discussion_likes').upsert(
        {
          'discussion_id': discussionId,
          'user_id': userId,
        },
        onConflict: 'discussion_id,user_id',
        ignoreDuplicates: true,
      );
    }
  }

  static Future<List<Map<String, dynamic>>> getComments(
    String discussionId,
  ) async {
    final response = await _db
        .from('discussion_comments')
        .select()
        .eq('discussion_id', discussionId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addComment({
    required String discussionId,
    required String content,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('Sign in to comment.');
    }

    final cleanContent = content.trim();

    if (cleanContent.isEmpty) {
      throw Exception('Write a reply first.');
    }

    await _db.from('discussion_comments').insert({
      'discussion_id': discussionId,
      'user_id': userId,
      'content': cleanContent,
    });
  }
}