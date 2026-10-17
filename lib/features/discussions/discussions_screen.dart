import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/app_theme.dart';
import '../../core/supabase_client.dart';

class DiscussionsScreen extends StatefulWidget {
  const DiscussionsScreen({super.key});

  @override
  State<DiscussionsScreen> createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen> {
  late Future<List<Map<String, dynamic>>> _posts;

  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _posts = _loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadPosts() async {
    final result = await supabase
        .from('discussions')
        .select('id, author_id, title, body, category, created_at')
        .eq('status', 'published')
        .order('created_at', ascending: false);

    final posts = List<Map<String, dynamic>>.from(result);

    if (posts.isEmpty) return posts;

    final authorIds = posts
        .map((post) => post['author_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    if (authorIds.isNotEmpty) {
      final profiles = await supabase
          .from('profiles')
          .select('id, display_name, avatar_url')
          .inFilter('id', authorIds);

      final profileMap = <String, Map<String, dynamic>>{};

      for (final profile in profiles) {
        profileMap[profile['id'].toString()] =
            Map<String, dynamic>.from(profile);
      }

      for (final post in posts) {
        post['profile'] = profileMap[post['author_id']?.toString()];
      }
    }

    final postIds = posts
        .map((post) => post['id'].toString())
        .toList();

    final likes = await supabase
        .from('discussion_likes')
        .select('discussion_id, user_id')
        .inFilter('discussion_id', postIds);

    final likeCounts = <String, int>{};
    final likedByMe = <String>{};
    final currentUserId = supabase.auth.currentUser?.id;

    for (final like in likes) {
      final postId = like['discussion_id'].toString();

      likeCounts[postId] = (likeCounts[postId] ?? 0) + 1;

      if (currentUserId != null &&
          like['user_id'].toString() == currentUserId) {
        likedByMe.add(postId);
      }
    }

    for (final post in posts) {
      final id = post['id'].toString();
      post['like_count'] = likeCounts[id] ?? 0;
      post['liked_by_me'] = likedByMe.contains(id);
    }

    return posts;
  }

  Future<void> _refresh() async {
    final future = _loadPosts();
    setState(() => _posts = future);

    try {
      await future;
    } catch (_) {
      // The FutureBuilder displays the error state.
    }
  }

  List<Map<String, dynamic>> _filterPosts(
    List<Map<String, dynamic>> posts,
  ) {
    final query = _search.trim().toLowerCase();

    if (query.isEmpty) return posts;

    return posts.where((post) {
      return (post['title'] ?? '').toString().toLowerCase().contains(query) ||
          (post['body'] ?? '').toString().toLowerCase().contains(query) ||
          (post['category'] ?? '').toString().toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussions'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: IconButton.filledTonal(
              tooltip: 'Notifications',
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ),
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              setState(() {
                if (_search.isNotEmpty) {
                  _search = '';
                  _searchController.clear();
                } else {
                  _search = ' ';
                  _searchController.clear();
                }
              });
            },
            icon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _posts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 90),
                  Icon(Icons.cloud_off_outlined, size: 48),
                  SizedBox(height: 16),
                  Center(child: Text('Could not load the community feed.')),
                  SizedBox(height: 8),
                  Center(child: Text('Pull down to try again.')),
                ],
              );
            }

            final allPosts = snapshot.data ?? [];
            final posts = _filterPosts(allPosts);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _CommunityBanner(onCreate: _createPost),
                const SizedBox(height: 22),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _search = value),
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Community feed',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${posts.length} ${posts.length == 1 ? 'post' : 'posts'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                if (posts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Column(
                      children: [
                        Icon(Icons.forum_outlined, size: 48),
                        SizedBox(height: 12),
                        Text('No discussions found.'),
                      ],
                    ),
                  )
                else
                  ...posts.map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _PostCard(
                        post: post,
                        onOpen: () => _openPost(post),
                        onLike: () => _toggleLike(post),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPost,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Create post'),
      ),
    );
  }

  Future<void> _createPost() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      _message('Please sign in before creating a post.');
      return;
    }

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _PostComposer(),
    );

    if (result == null || !mounted) return;

    try {
      await supabase.from('discussions').insert({
        'author_id': user.id,
        'title': result['title'],
        'body': result['body'],
        'category': result['category'],
        'status': 'published',
      });

      if (!mounted) return;

      await _refresh();
      _message('Your post has been published.');
    } catch (error) {
      if (!mounted) return;
      _message('Could not publish your post. Please try again.');
    }
  }

  Future<void> _toggleLike(Map<String, dynamic> post) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      _message('Please sign in to like discussions.');
      return;
    }

    final postId = post['id'].toString();
    final wasLiked = post['liked_by_me'] == true;

    try {
      if (wasLiked) {
        await supabase
            .from('discussion_likes')
            .delete()
            .eq('discussion_id', postId)
            .eq('user_id', user.id);
      } else {
        await supabase.from('discussion_likes').insert({
          'discussion_id': postId,
          'user_id': user.id,
        });
      }

      if (!mounted) return;
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      _message('Could not update your like. Please try again.');
    }
  }

  Future<void> _openPost(Map<String, dynamic> post) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DiscussionDetailScreen(discussion: post),
      ),
    );

    if (mounted) {
      await _refresh();
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _CommunityBanner extends StatelessWidget {
  const _CommunityBanner({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.forum_rounded, size: 28),
              SizedBox(width: 10),
              Text(
                'ESSAX COMMUNITY',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Good ideas grow together.',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your progress, ask questions, and learn from the community.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Share an update'),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.onOpen,
    required this.onLike,
  });

  final Map<String, dynamic> post;
  final VoidCallback onOpen;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = post['profile'] is Map
        ? Map<String, dynamic>.from(post['profile'] as Map)
        : <String, dynamic>{};

    final name = (profile['display_name'] ?? 'Community member').toString();
    final avatarUrl = profile['avatar_url']?.toString();
    final liked = post['liked_by_me'] == true;
    final likeCount = post['like_count'] as int? ?? 0;
    final category = (post['category'] ?? 'General').toString();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? const Icon(Icons.person_outline_rounded)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatDate(post['created_at']),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              (post['title'] ?? 'Discussion').toString(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              (post['body'] ?? '').toString(),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.tag, size: 16),
                label: Text(category),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onLike,
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? AppTheme.primaryColor : null,
                  ),
                  label: Text('$likeCount'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Comments'),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Open discussion',
                  onPressed: onOpen,
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Recently';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return 'Recently';

    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}

class _PostComposer extends StatefulWidget {
  const _PostComposer();

  @override
  State<_PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<_PostComposer> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();

  String _category = 'General';

  static const _categories = [
    'General',
    'Projects',
    'Development',
    'Design',
    'Questions',
    'Achievements',
  ];

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a post',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _title,
                maxLength: 180,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Enter a title of at least 3 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _body,
                minLines: 4,
                maxLines: 7,
                maxLength: 20000,
                decoration: const InputDecoration(
                  labelText: 'What would you like to share?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Write something before publishing.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    Navigator.of(context).pop({
                      'title': _title.text.trim(),
                      'body': _body.text.trim(),
                      'category': _category,
                    });
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Publish post'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscussionDetailScreen extends StatefulWidget {
  const DiscussionDetailScreen({
    super.key,
    required this.discussion,
  });

  final Map<String, dynamic> discussion;

  @override
  State<DiscussionDetailScreen> createState() =>
      _DiscussionDetailScreenState();
}

class _DiscussionDetailScreenState extends State<DiscussionDetailScreen> {
  late Future<List<Map<String, dynamic>>> _comments;
  final TextEditingController _commentController = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _comments = _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadComments() async {
    final result = await supabase
        .from('discussion_comments')
        .select('id, discussion_id, author_id, body, created_at')
        .eq('discussion_id', widget.discussion['id'])
        .order('created_at', ascending: true);

    final comments = List<Map<String, dynamic>>.from(result);
    final ids = comments
        .map((comment) => comment['author_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    if (ids.isNotEmpty) {
      final profiles = await supabase
          .from('profiles')
          .select('id, display_name, avatar_url')
          .inFilter('id', ids);

      final profileMap = <String, Map<String, dynamic>>{};

      for (final profile in profiles) {
        profileMap[profile['id'].toString()] =
            Map<String, dynamic>.from(profile);
      }

      for (final comment in comments) {
        comment['profile'] = profileMap[comment['author_id']?.toString()];
      }
    }

    return comments;
  }

  Future<void> _sendComment() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      _message('Please sign in before commenting.');
      return;
    }

    final body = _commentController.text.trim();

    if (body.isEmpty) {
      _message('Write a comment first.');
      return;
    }

    if (body.length > 10000) {
      _message('Your comment is too long.');
      return;
    }

    setState(() => _sending = true);

    try {
      await supabase.from('discussion_comments').insert({
        'discussion_id': widget.discussion['id'],
        'author_id': user.id,
        'body': body,
      });

      _commentController.clear();

      if (!mounted) return;

      final future = _loadComments();
      setState(() => _comments = future);
      await future;
    } catch (_) {
      if (!mounted) return;
      _message('Could not send your comment. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = widget.discussion['profile'] is Map
        ? Map<String, dynamic>.from(widget.discussion['profile'] as Map)
        : <String, dynamic>{};

    return Scaffold(
      appBar: AppBar(title: const Text('Discussion')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            (widget.discussion['category'] ?? 'General')
                .toString()
                .toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            (widget.discussion['title'] ?? 'Discussion').toString(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            (profile['display_name'] ?? 'Community member').toString(),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          Text(
            (widget.discussion['body'] ?? '').toString(),
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Comments',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _comments,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return const Text('Could not load comments.');
              }

              final comments = snapshot.data ?? [];

              if (comments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Be the first to comment.'),
                );
              }

              return Column(
                children: comments.map((comment) {
                  final commentProfile = comment['profile'] is Map
                      ? Map<String, dynamic>.from(comment['profile'] as Map)
                      : <String, dynamic>{};

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(
                      (commentProfile['display_name'] ?? 'Community member')
                          .toString(),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(comment['body'].toString()),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _commentController,
            minLines: 1,
            maxLines: 4,
            maxLength: 10000,
            decoration: InputDecoration(
              hintText: 'Write a comment...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              suffixIcon: IconButton(
                tooltip: 'Send comment',
                onPressed: _sending ? null : _sendComment,
                icon: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ),
            onSubmitted: (_) {
              if (!_sending) _sendComment();
            },
          ),
        ],
      ),
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _loadNotifications();
  }

  Future<List<Map<String, dynamic>>> _loadNotifications() async {
    final user = supabase.auth.currentUser;

    if (user == null) return [];

    final result = await supabase
        .from('notifications')
        .select(
          'id, message, notification_type, discussion_id, read_at, created_at',
        )
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(100);

    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> _markRead(Map<String, dynamic> notification) async {
    final user = supabase.auth.currentUser;

    if (user == null || notification['read_at'] != null) return;

    try {
      await supabase
          .from('notifications')
          .update({'read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', notification['id'])
          .eq('user_id', user.id);

      if (!mounted) return;

      setState(() {
        notification['read_at'] = DateTime.now().toIso8601String();
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update notification.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load notifications.'),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 56),
                    SizedBox(height: 16),
                    Text('You’re all caught up.'),
                    SizedBox(height: 8),
                    Text(
                      'Likes and comments on your discussions will appear here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final read = notification['read_at'] != null;
              final isLike = notification['notification_type'] == 'like';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppTheme.primaryColor.withValues(alpha: 0.15),
                    child: Icon(
                      isLike
                          ? Icons.favorite_outline
                          : Icons.chat_bubble_outline,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(notification['message'].toString()),
                  subtitle: Text(_formatDate(notification['created_at'])),
                  trailing: read
                      ? null
                      : const Icon(
                          Icons.circle,
                          size: 10,
                          color: AppTheme.primaryColor,
                        ),
                  onTap: () async {
                    await _markRead(notification);

                    if (!mounted) return;

                    final discussionId = notification['discussion_id'];

                    if (discussionId == null) return;

                    try {
                      final result = await supabase
                          .from('discussions')
                          .select(
                            'id, author_id, title, body, category, created_at',
                          )
                          .eq('id', discussionId)
                          .eq('status', 'published')
                          .maybeSingle();

                      if (!mounted) return;

                      if (result == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('This discussion is no longer available.'),
                          ),
                        );
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DiscussionDetailScreen(
                            discussion: Map<String, dynamic>.from(result),
                          ),
                        ),
                      );
                    } catch (_) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open this discussion.'),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Recently';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return 'Recently';

    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}
                  