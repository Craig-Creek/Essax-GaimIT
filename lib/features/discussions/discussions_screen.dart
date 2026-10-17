import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'community_service.dart';
import 'create_discussion_screen.dart';
import 'discussion_comments_screen.dart';
import 'widgets/community_post_card.dart';
import 'widgets/community_topics.dart';

class DiscussionsScreen extends StatefulWidget {
  const DiscussionsScreen({super.key});

  @override
  State<DiscussionsScreen> createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen> {
  static const _filters = [
    'For You',
    'Following',
    'Trending',
    'Questions',
  ];

  String _filter = 'For You';
  String _topic = 'All';
  String _search = '';
  bool _searching = false;

  late Future<List<Map<String, dynamic>>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }

  void _refreshPosts() {
    _postsFuture = CommunityService.getPosts(
      filter: _filter,
      query: _search,
    );
  }

  Future<void> _refresh() async {
    setState(_refreshPosts);
    await _postsFuture;
  }

  Future<void> _createPost() async {
    if (CommunityService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to join the community.')),
      );
      return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const CreateDiscussionScreen(),
      ),
    );

    if (created == true && mounted) {
      setState(_refreshPosts);
    }
  }

  Future<void> _openComments(Map<String, dynamic> post) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DiscussionCommentsScreen(post: post),
      ),
    );

    if (mounted) setState(_refreshPosts);
  }

  Future<void> _like(Map<String, dynamic> post) async {
    if (CommunityService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to like a discussion.')),
      );
      return;
    }

    final wasLiked = post['is_liked'] as bool? ?? false;

    setState(() {
      post['is_liked'] = !wasLiked;

      final count = post['like_count'] as int? ?? 0;
      post['like_count'] = wasLiked
          ? (count > 0 ? count - 1 : 0)
          : count + 1;
    });

    try {
      await CommunityService.toggleLike(
        discussionId: post['id'].toString(),
        currentlyLiked: wasLiked,
      );
    } catch (error) {
      if (!mounted) return;

      setState(_refreshPosts);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update like: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPost,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Start a discussion'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESSAX COMMUNITY',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.primaryColor,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Discussions',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          setState(() {
                            _searching = !_searching;
                            if (!_searching) {
                              _search = '';
                              _refreshPosts();
                            }
                          });
                        },
                        icon: const Icon(Icons.search_rounded),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Notifications will be connected next.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.notifications_none_rounded),
                      ),
                    ],
                  ),
                ),
              ),

              if (_searching)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search discussions...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onChanged: (value) => _search = value,
                      onSubmitted: (_) => setState(_refreshPosts),
                    ),
                  ),
                ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withValues(alpha: 0.78),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR COMMUNITY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'The game is better together.',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Share your takes. Debate the big moments. '
                          'Find your people.',
                          style: TextStyle(
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _createPost,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryColor,
                          ),
                          child: const Text('Join the conversation'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Explore topics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: CommunityTopics(
                    selectedTopic: _topic,
                    onSelected: (value) => setState(() => _topic = value),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Community feed',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final selected = _filter == filter;

                        return ChoiceChip(
                          label: Text(filter),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _filter = filter;
                              _refreshPosts();
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _postsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                            ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: _EmptyFeed(
                          title: 'Could not load discussions',
                          message:
                              'Check your connection and database permissions.',
                          onPressed: () => setState(_refreshPosts),
                        ),
                      );
                    }

                    final posts = (snapshot.data ?? []).where((post) {
                      if (_topic == 'All') return true;

                      return (post['category']?.toString().toLowerCase() ??
                              '') ==
                          _topic.toLowerCase();
                    }).toList();

                    if (posts.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _EmptyFeed(
                          title: 'Start the conversation',
                          message:
                              'Your community needs your voice. Publish the first post.',
                          onPressed: _createPost,
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: CommunityPostCard(
                              key: ValueKey(post['id']),
                              post: post,
                              onLike: () => _like(post),
                              onComment: () => _openComments(post),
                            ),
                          );
                        },
                        childCount: posts.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({
    required this.title,
    required this.message,
    required this.onPressed,
  });

  final String title;
  final String message;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.forum_outlined,
            size: 42,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onPressed,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}