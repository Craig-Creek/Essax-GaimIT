import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'home_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _competitionsFuture;
  late Future<List<Map<String, dynamic>>> _discussionsFuture;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  void _loadHomeData() {
    _competitionsFuture = HomeService.getUpcomingCompetitions();
    _discussionsFuture = HomeService.getRecentDiscussions();
  }

  Future<void> _refresh() async {
    setState(_loadHomeData);

    await Future.wait([
      _competitionsFuture,
      _discussionsFuture,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildPageTitle(),
                    const SizedBox(height: 28),
                    _buildSectionHeading(
                      'Upcoming competitions',
                      Icons.emoji_events_outlined,
                    ),
                    const SizedBox(height: 14),
                    _buildCompetitions(),
                    const SizedBox(height: 32),
                    _buildSectionHeading(
                      'Recent discussions',
                      Icons.forum_outlined,
                    ),
                    const SizedBox(height: 14),
                    _buildDiscussions(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Text(
      'Home',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppTheme.text,
          ),
    );
  }

  Widget _buildSectionHeading(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 23),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompetitions() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _competitionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingContent();
        }

        if (snapshot.hasError) {
          return _ErrorContent(
            message: 'Could not load competitions.',
            onRetry: () {
              setState(() {
                _competitionsFuture =
                    HomeService.getUpcomingCompetitions();
              });
            },
          );
        }

        final competitions = snapshot.data ?? [];

        if (competitions.isEmpty) {
          return const _EmptyContent(
            icon: Icons.emoji_events_outlined,
            message: 'No upcoming competitions yet.',
          );
        }

        return Column(
          children: competitions
              .map((competition) => _CompetitionCard(
                    competition: competition,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildDiscussions() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _discussionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingContent();
        }

        if (snapshot.hasError) {
          return _ErrorContent(
            message: 'Could not load discussions.',
            onRetry: () {
              setState(() {
                _discussionsFuture =
                    HomeService.getRecentDiscussions();
              });
            },
          );
        }

        final discussions = snapshot.data ?? [];

        if (discussions.isEmpty) {
          return const _EmptyContent(
            icon: Icons.forum_outlined,
            message: 'No discussions have been published yet.',
          );
        }

        return Column(
          children: discussions
              .map((discussion) => _DiscussionCard(
                    discussion: discussion,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  const _CompetitionCard({required this.competition});

  final Map<String, dynamic> competition;

  @override
  Widget build(BuildContext context) {
    final title = competition['title']?.toString() ?? 'Untitled competition';
    final description =
        competition['description']?.toString().trim() ?? '';
    final imageUrl = competition['image_url']?.toString();
    final startsAt = DateTime.tryParse(
      competition['starts_at']?.toString() ?? '',
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.muted.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null && imageUrl.trim().isNotEmpty)
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text,
                      ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.muted,
                        ),
                  ),
                ],
                if (startsAt != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Starts ${_formatDate(startsAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.muted,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscussionCard extends StatelessWidget {
  const _DiscussionCard({required this.discussion});

  final Map<String, dynamic> discussion;

  @override
  Widget build(BuildContext context) {
    final title = discussion['title']?.toString() ?? 'Untitled discussion';
    final body = discussion['body']?.toString().trim() ?? '';
    final category = discussion['category']?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.muted.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category != null && category.trim().isNotEmpty) ...[
              Text(
                category,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text,
                  ),
            ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.muted,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: AppTheme.muted.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: AppTheme.muted),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(color: AppTheme.error),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}