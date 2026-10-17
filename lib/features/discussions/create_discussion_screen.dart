import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'community_service.dart';

class CreateDiscussionScreen extends StatefulWidget {
  const CreateDiscussionScreen({super.key});

  @override
  State<CreateDiscussionScreen> createState() =>
      _CreateDiscussionScreenState();
}

class _CreateDiscussionScreenState extends State<CreateDiscussionScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _category = 'MatchDay';
  bool _publishing = false;

  final _categories = const [
    'MatchDay',
    'TeamTalk',
    'WeekendLeague',
    'Predictions',
    'Questions',
    'General',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_publishing) return;

    setState(() => _publishing = true);

    try {
      await CommunityService.createPost(
        title: _titleController.text,
        content: _contentController.text,
        category: _category,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start a discussion')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Your community. Your voice.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Share an opinion, ask a question, or get the conversation going.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Choose a topic',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final selected = _category == category;

                return ChoiceChip(
                  label: Text('#$category'),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                  ),
                  onSelected: (_) => setState(() => _category = category),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              maxLength: 150,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Discussion title',
                hintText: 'What is on your mind?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              minLines: 6,
              maxLines: 12,
              maxLength: 5000,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Your message',
                hintText: 'Bring the community into the conversation...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _publishing ? null : _publish,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                icon: _publishing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _publishing ? 'Publishing...' : 'Publish discussion',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}