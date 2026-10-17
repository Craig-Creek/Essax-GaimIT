import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'teams_service.dart';

class TeamDetailsScreen extends StatefulWidget {
  const TeamDetailsScreen({
    super.key,
    required this.team,
  });

  final Map<String, dynamic> team;

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  bool _isRequesting = false;
  String? _membershipStatus;
  bool _loadingStatus = true;

  String get _teamId => widget.team['id'].toString();

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final status = await TeamsService.getMembershipStatus(_teamId);

      if (!mounted) return;

      setState(() {
        _membershipStatus = status;
        _loadingStatus = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingStatus = false);
    }
  }

  Future<void> _requestJoin() async {
    setState(() => _isRequesting = true);

    try {
      await TeamsService.requestToJoin(_teamId);
      await _loadStatus();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your membership request has been submitted.'),
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
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final team = widget.team;

    final name = team['name']?.toString() ?? 'Team';
    final description =
        team['description']?.toString() ?? 'No description yet.';

    final isOwner = team['owner_id'] == TeamsService.currentUserId;
    final isMember = _membershipStatus == 'active';
    final isPending = _membershipStatus == 'pending';
    final memberCount = team['member_count'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            height: 170,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Colors.white,
              size: 72,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.people_alt_rounded,
                color: AppTheme.primaryColor,
              ),
              title: const Text('Team members'),
              subtitle: Text('$memberCount of 10 active members'),
            ),
          ),
          const SizedBox(height: 20),
          if (_loadingStatus)
            const Center(child: CircularProgressIndicator())
          else if (isOwner)
            const Card(
              child: ListTile(
                leading: Icon(Icons.workspace_premium_rounded),
                title: Text('You own this team'),
                subtitle: Text('Manage your team and membership requests.'),
              ),
            )
          else if (isMember)
            const Card(
              child: ListTile(
                leading: Icon(Icons.check_circle_rounded),
                title: Text('You are a member'),
              ),
            )
          else if (isPending)
            const Card(
              child: ListTile(
                leading: Icon(Icons.hourglass_top_rounded),
                title: Text('Request pending'),
                subtitle: Text('The team owner must review your request.'),
              ),
            )
          else
            FilledButton.icon(
              onPressed: _isRequesting || memberCount >= 10
                  ? null
                  : _requestJoin,
              icon: const Icon(Icons.group_add_rounded),
              label: Text(
                memberCount >= 10
                    ? 'Team is full'
                    : _isRequesting
                        ? 'Submitting request...'
                        : 'Request to join',
              ),
            ),
        ],
      ),
    );
  }
}