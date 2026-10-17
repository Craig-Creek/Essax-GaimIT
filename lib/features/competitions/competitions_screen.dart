import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'competition_details_screen.dart';
import 'competitions_service.dart';
import 'widgets/competition_banner.dart';
import 'widgets/competition_card.dart';

class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({super.key});

  @override
  State<CompetitionsScreen> createState() =>
      _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {
  late Future<List<Map<String, dynamic>>> _competitionsFuture;

  final TextEditingController _searchController =
      TextEditingController();

  bool _searchVisible = false;

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
    _competitionsFuture = CompetitionsService.getCompetitions(
      search: _searchController.text,
    );
  }

  Future<void> _refresh() async {
    final future = CompetitionsService.getCompetitions(
      search: _searchController.text,
    );

    setState(() {
      _competitionsFuture = future;
    });

    await future;
  }

  void _search() {
    setState(() {
      _searchVisible = !_searchVisible;

      if (!_searchVisible) {
        _searchController.clear();
      }

      _loadCompetitions();
    });
  }

  void _applySearch(String value) {
    setState(_loadCompetitions);
  }

  void _openCompetition(Map<String, dynamic> competition) {
    final id = competition['id'];

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This competition has no valid ID.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CompetitionDetailsScreen(
          competitionId: id,
          initialCompetition: competition,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Competitions'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              tooltip: _searchVisible
                  ? 'Close search'
                  : 'Search competitions',
              onPressed: _search,
              style: IconButton.styleFrom(
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                _searchVisible
                    ? Icons.close_rounded
                    : Icons.search_rounded,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const CompetitionBanner(),
                  const SizedBox(height: 28),
                  if (_searchVisible) ...[
                    TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _applySearch,
                      decoration: const InputDecoration(
                        hintText: 'Search competitions',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Explore competitions',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover challenges, show what you can do, '
                    'and compete with the Essax community.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _competitionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Could not load competitions.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: _refresh,
                              child: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 58,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No competitions found',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchVisible
                                  ? 'Try a different search.'
                                  : 'New competitions will appear here '
                                      'when they are published.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final competition = items[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: CompetitionCard(
                            competition: competition,
                            onTap: () =>
                                _openCompetition(competition),
                          ),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}