import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/supabase_client.dart';

class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({super.key});

  @override
  State<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {
  late Future<List<Map<String, dynamic>>> _competitions;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _searchOpen = false;

  @override
  void initState() {
    super.initState();
    _loadCompetitions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCompetitions() {
    _competitions = supabase
        .from('competitions')
        .select('id, title, description, starts_at, ends_at')
        .eq('status', 'published')
        .order('created_at', ascending: false);
  }

  Future<void> _refresh() async {
    setState(_loadCompetitions);
    await _competitions;
  }

  List<Map<String, dynamic>> _filterItems(
    List<Map<String, dynamic>> items,
  ) {
    if (_searchQuery.trim().isEmpty) return items;

    final query = _searchQuery.toLowerCase();

    return items.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      final description =
          (item['description'] ?? '').toString().toLowerCase();

      return title.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Competitions'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              tooltip: 'Search competitions',
              onPressed: () {
                setState(() {
                  _searchOpen = !_searchOpen;
                  if (!_searchOpen) {
                    _searchController.clear();
                    _searchQuery = '';
                  }
                });
              },
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(_searchOpen ? Icons.close : Icons.search),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _competitions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 100),
                  Icon(Icons.cloud_off_outlined, size: 48),
                  SizedBox(height: 16),
                  Center(child: Text('Could not load competitions.')),
                  SizedBox(height: 8),
                  Center(child: Text('Pull down to try again.')),
                ],
              );
            }

            final allItems = snapshot.data ?? [];
            final items = _filterItems(allItems);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                if (_searchOpen) ...[
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search competitions...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Featured banner: 16:4 ratio.
                _FeaturedBanner(
                  onExplore: () {
                    if (items.isNotEmpty) {
                      _openCompetition(items.first);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No competitions to explore yet.'),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 28),

                Text(
                  'Find your next challenge',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Discover opportunities to compete, learn, and grow.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Open competitions'
                            : 'Search results',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${items.length} ${items.length == 1 ? 'event' : 'events'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (items.isEmpty)
                  _EmptyCompetitions(
                    searching: _searchQuery.isNotEmpty,
                  )
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: _CompetitionGalleryCard(
                        item: item,
                        onTap: () => _openCompetition(item),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openCompetition(Map<String, dynamic> item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CompetitionDetailScreen(competition: item),
      ),
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: 4,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -16,
              bottom: -28,
              child: Icon(
                Icons.emoji_events_rounded,
                size: 150,
                color: Colors.white.withValues(alpha: 0.13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ESSAX ARENA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your next big win starts here.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton(
                          onPressed: onExplore,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Explore'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompetitionGalleryCard extends StatelessWidget {
  const _CompetitionGalleryCard({
    required this.item,
    required this.onTap,
  });

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (item['title'] ?? 'Competition').toString();
    final description = (item['description'] ?? '').toString();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gallery artwork: 16:9.5.
            AspectRatio(
              aspectRatio: 16 / 9.5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    child: const Center(
                      child: Icon(
                        Icons.emoji_events_rounded,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'OPEN COMPETITION',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _dateLabel(item['ends_at']),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      FilledButton(
                        onPressed: onTap,
                        child: const Text('View details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(dynamic value) {
    if (value == null) return 'Dates to be announced';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return 'Dates to be announced';

    return 'Ends ${date.toLocal().day}/${date.toLocal().month}/${date.toLocal().year}';
  }
}

class _EmptyCompetitions extends StatelessWidget {
  const _EmptyCompetitions({required this.searching});

  final bool searching;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_outlined, size: 52),
          const SizedBox(height: 14),
          Text(
            searching
                ? 'No matching competitions'
                : 'No published competitions yet',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            searching
                ? 'Try a different search.'
                : 'New challenges will appear here.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CompetitionDetailScreen extends StatefulWidget {
  const CompetitionDetailScreen({
    super.key,
    required this.competition,
  });

  final Map<String, dynamic> competition;

  @override
  State<CompetitionDetailScreen> createState() =>
      _CompetitionDetailScreenState();
}

class _CompetitionDetailScreenState extends State<CompetitionDetailScreen> {
  String _section = 'Overview';
  bool _joining = false;

  static const _sections = [
    'Overview',
    'Rules',
    'Leaderboard',
    'Submissions',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.competition;
    final title = (item['title'] ?? 'Competition').toString();
    final description = (item['description'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Competition'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9.5,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.event_available_outlined,
                label: 'Published',
              ),
              _InfoChip(
                icon: Icons.schedule_outlined,
                label: _dateLabel(item['ends_at']),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _sections.map((section) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(section),
                    selected: _section == section,
                    onSelected: (_) {
                      setState(() => _section = section);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            _section,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            switch (_section) {
              'Rules' =>
                'Competition rules and eligibility details will be published by the organiser.',
              'Leaderboard' =>
                'The leaderboard will appear here when competition results are available.',
              'Submissions' =>
                'Submission instructions and entries will appear here when enabled.',
              _ => description.isEmpty
                  ? 'More information about this competition will be announced soon.'
                  : description,
            },
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton.icon(
          onPressed: _joining ? null : _joinCompetition,
          icon: _joining
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.emoji_events_outlined),
          label: Text(_joining ? 'Joining...' : 'Join Competition'),
        ),
      ),
    );
  }

  String _dateLabel(dynamic value) {
    if (value == null) return 'Date TBA';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return 'Date TBA';

    final local = date.toLocal();
    return 'Ends ${local.day}/${local.month}/${local.year}';
  }

  Future<void> _joinCompetition() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      _showMessage(
        'Sign-in is required before you can join a competition.',
      );
   