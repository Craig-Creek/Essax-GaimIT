import 'package:flutter/material.dart';

import '../../core/supabase_client.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  late Future<List<Map<String, dynamic>>> _teams;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  void _loadTeams() {
    _teams = supabase
        .from('teams')
        .select('id, name, description')
        .eq('is_public', true)
        .order('created_at', ascending: false);
  }

  Future<void> _refresh() async {
    setState(_loadTeams);
    await _teams;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teams')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _teams,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(child: Text('Could not load teams.\n${snapshot.error}')),
                ],
              );
            }

            final items = snapshot.data ?? [];

            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.groups_outlined, size: 56),
                  Center(child: Text('No public teams yet.')),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.groups_outlined),
                    title: Text(item['name']?.toString() ?? 'Team'),
                    subtitle: Text(
                      item['description']?.toString() ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}