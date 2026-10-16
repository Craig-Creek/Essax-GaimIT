import 'package:flutter/material.dart';

import '../../core/supabase_client.dart';

class DiscussionsScreen extends StatefulWidget {
  const DiscussionsScreen({super.key});

  @override
  State<DiscussionsScreen> createState() => _DiscussionsScreenState();
}

class _DiscussionsScreenState extends State<DiscussionsScreen> {
  late Future<List<Map<String, dynamic>>> _discussions;

  @override
  void initState() {
    super.initState();
    _loadDiscussions();
  }

  void _loadDiscussions() {
    _discussions = supabase
        .from('discussions')
        .select('id, title, body, category')
        .eq('status', 'published')
        .order('created_at', ascending: false);
  }

  Future<void> _refresh() async {
    setState(_loadDiscussions);
    await _discussions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discussions')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _discussions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(child: Text('Could not load discussions.\n${snapshot.error}')),
                ],
              );
            }

            final items = snapshot.data ?? [];

            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.forum_outlined, size: 56),
                  Center(child: Text('No discussions yet.')),
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
                    leading: const Icon(Icons.forum_outlined),
                    title: Text(item['title']?.toString() ?? 'Discussion'),
                    subtitle: Text(
                      item['body']?.toString() ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: item['category'] == null
                        ? null
                        : Text(item['category'].toString()),
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