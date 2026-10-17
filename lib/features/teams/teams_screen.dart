import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'create_team_screen.dart';
import 'team_details_screen.dart';
import 'teams_service.dart';
import 'widgets/create_team_banner.dart';
import 'widgets/team_card.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  late Future<List<Map<String, dynamic>>> _teamsFuture;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  void _loadTeams() {
    _teamsFuture = TeamsService.getTeams();
  }

  Future<void> _refresh() async {
    final future = TeamsService.getTeams();

    setState(() {
      _teamsFuture = future;
    });

    await future;
  }

  Future<void> _openCreateTeam() async {
    if (TeamsService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to create a team.'),
        ),
      );
      return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const CreateTeamScreen(),
      ),
    );

    if (created == true && mounted) {
      await _refresh();
    }
  }

  void _openTeam(Map<String, dynamic> team) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TeamDetailsScreen(team: team),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        actions: [
          IconButton(
            tooltip: 'Refresh teams',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  CreateTeamBanner(
                    onCreate: _openCreateTeam,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Find your team',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover communities, request to join, '
                    'and compete together.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _teamsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                              'Could not load teams.',
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

                final teams = snapshot.data ?? [];

                if (teams.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.groups_rounded,
                              size: 60,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your community starts here',
                              style: theme.textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Create a team or check back for '
                              'more teams to discover.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              onPressed: _openCreateTeam,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Create a team'),
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
                        final team = teams[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TeamCard(
                            team: team,
                            onTap: () => _openTeam(team),
                          ),
                        );
                      },
                      childCount: teams.length,
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