import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  final Map<String, dynamic> post;
  final VoidCallback onLike;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final title = post['title']?.toString() ?? '';
    final content = post['content']?.toString() ?? '';
    final category = post['category']?.toString() ?? 'General';

    final createdAt = DateTime.tryParse(
      post['created_at']?.toString() ?? '',
    );

    final likes = post['like_count'] as int? ?? 0;
    final comments = post['comment_count'] as int? ?? 0;
    final liked = post['is_liked'] as bool? ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    AppTheme.secondaryColor.withValues(alpha: 0.25),
                child: Icon(
                  Icons.person_rounded,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community member',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      _timeAgo(createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.55),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz_rounded),
            ],
          ),
          const SizedBox(height: 16),
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '#$category',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: colors.outline.withValues(alpha: 0.12),
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: onLike,
                icon: Icon(
                  liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: liked ? AppTheme.primaryColor : null,
                ),
                label: Text('$likes'),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: onComment,
                icon: const Icon(Icons.mode_comment_outlined),
                label: Text('$comments replies'),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Share',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sharing will be added next.'),
                    ),
                  );
                },
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return 'Recently';

    final difference = DateTime.now().difference(date.toLocal());

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}