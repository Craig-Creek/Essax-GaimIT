import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class CommunityTopics extends StatelessWidget {
  const CommunityTopics({
    super.key,
    required this.selectedTopic,
    required this.onSelected,
  });

  final String selectedTopic;
  final ValueChanged<String> onSelected;

  static const topics = [
    'All',
    'MatchDay',
    'TeamTalk',
    'WeekendLeague',
    'Predictions',
    'Questions',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final topic = topics[index];
          final selected = selectedTopic == topic;

          return ChoiceChip(
            label: Text(topic == 'All' ? 'All topics' : '#$topic'),
            selected: selected,
            onSelected: (_) => onSelected(topic),
            selectedColor: AppTheme.primaryColor,
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}