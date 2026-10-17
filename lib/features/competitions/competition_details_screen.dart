import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'competitions_service.dart';

class CompetitionDetailsScreen extends StatefulWidget {
  const CompetitionDetailsScreen({
    super.key,
    required this.competitionId,
    this.initialCompetition,
  });

  final Object competitionId;
  final Map<String, dynamic>? initialCompetition;

  @override
  State<CompetitionDetailsScreen> createState() =>
      _CompetitionDetailsScreenState();
}

class _CompetitionDetailsScreenState
    extends State<CompetitionDetailsScreen> {
  late Future<Map<String, dynamic>> _competitionFuture;

  int _selectedSection = 0;

  @override
  void initState() {
    super.initState();

    _competitionFuture =
        CompetitionsService.getCompetitionById(
      widget.competitionId,
    );
  }

  Future<void> _refresh() async {
    final future = CompetitionsService.getCompetitionById(
      widget.competitionId,
    );

    setState(() {
      _competitionFuture = future;
    });

    await future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _competitionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Could not load this competition.',
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
              );
            }

            final competition = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        title: const Text('Competition'),
                        leading: IconButton(
                          tooltip: 'Go back',
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          12,
                          20,
                          24,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildHero(),
                            const SizedBox(height: 24),
                            Text(
                              competition['title']?.toString() ??
                                  'Competition',
                              style: theme.textTheme.headlineMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              competition['description']?.toString() ??
                                  'More information about this competition '
                                      'will be available soon.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.75),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildSectionChips(),
                            const SizedBox(height: 20),
                            _buildSelectedSection(competition),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildJoinBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHero() {
    return AspectRatio(
      aspectRatio: 16 / 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Center(
          child: Icon(
            Icons.emoji_events_rounded,
            size: 72,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionChips() {
    const labels = [
      'Overview',
      'Rules',
      'Leaderboard',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(labels.length, (index) {
        return ChoiceChip(
          label: Text(labels[index]),
          selected: _selectedSection == index,
          onSelected: (_) {
            setState(() {
              _selectedSection = index;
            });
          },
        );
      }),
    );
  }

  Widget _buildSelectedSection(
    Map<String, dynamic> competition,
  ) {
    final theme = Theme.of(context);

    switch (_selectedSection) {
      case 1:
        return _infoCard(
          icon: Icons.rule_rounded,
          title: 'Competition rules',
          body:
              'Review the official requirements before participating. '
              'Competition-specific rules will appear here once they '
              'are configured by the organizer.',
        );

      case 2:
        return _infoCard(
          icon: Icons.leaderboard_rounded,
          title: 'Leaderboard',
          body:
              'The leaderboard will show participant rankings and '
              'results when competition scoring is configured.',
        );

      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About this competition',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _infoCard(
              icon: Icons.flag_rounded,
              title: 'Your challenge',
              body: competition['description']?.toString() ??
                  'Competition details will appear here.',
            ),
            const SizedBox(height: 12),
            _infoCard(
              icon: Icons.groups_rounded,
              title: 'Participation',
              body:
                  'Check the competition rules and registration '
                  'requirements before joining.',
            ),
          ],
        );
    }
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _joinCompetition,
            icon: const Icon(Icons.emoji_events_rounded),
            label: const Text('Join Competition'),
          ),
        ),
      ),
    );
  }

  Future<void> _joinCompetition() async {
    try {
      await CompetitionsService.joinCompetition(
        widget.competitionId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have joined the competition.'),
        ),
      );
    } on UnimplementedError catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Registration is not configured.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }
}