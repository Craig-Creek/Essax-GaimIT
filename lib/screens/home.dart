import 'package:flutter/material.dart';
import '../main.dart';
import '../models/essay.dart';
import '../widgets/brand_header.dart';

class HomeScreen extends StatelessWidget {
  final List<Essay> essays;
  final VoidCallback onNew;
  final ValueChanged<Essay> onOpen;
  final ValueChanged<Essay> onFavorite;

  const HomeScreen({
    super.key,
    required this.essays,
    required this.onNew,
    required this.onOpen,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final recent = [...essays]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: BrandHeader(
            title: 'Write something great.',
            subtitle: 'Turn your ideas into polished essays.',
            trailing: CircleAvatar(
              radius: 23,
              backgroundColor: Colors.white.withOpacity(.18),
              child: const Icon(Icons.edit_rounded, color: Colors.white),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              GestureDetector(
                onTap: onNew,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 20,
                        offset: Offset(0, 8),
                        color: Color(0x10000000),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kRed, kOrange],
                          ),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start a new essay',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            SizedBox(height: 4),
                            Text('Open a clean page and start writing.',
                                style: TextStyle(color: kMuted, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(
                    child: Text('Recent essays',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  Text('${essays.length} total',
                      style: const TextStyle(color: kMuted, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              if (recent.isEmpty)
                _Empty(onNew: onNew)
              else
                ...recent.take(5).map((essay) => _EssayCard(
                      essay: essay,
                      onOpen: () => onOpen(essay),
                      onFavorite: () => onFavorite(essay),
                    )),
            ]),
          ),
        ),
      ],
    );
  }
}

class _EssayCard extends StatelessWidget {
  final Essay essay;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;

  const _EssayCard({
    required this.essay,
    required this.onOpen,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: onOpen,
        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
        leading: Container(
          width: 44,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEEE9),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.description_rounded, color: kRed),
        ),
        title: Text(
          essay.title.isEmpty ? 'Untitled essay' : essay.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            essay.content.trim().isEmpty ? 'No content yet' : essay.content.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: kMuted, fontSize: 12),
          ),
        ),
        trailing: IconButton(
          onPressed: onFavorite,
          icon: Icon(
            essay.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: essay.favorite ? kRed : kMuted,
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final VoidCallback onNew;
  const _Empty({required this.onNew});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            const Icon(Icons.auto_stories_outlined, size: 42, color: kOrange),
            const SizedBox(height: 12),
            const Text('Your essays will appear here.',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Start your first one and build your writing library.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kMuted, fontSize: 13)),
            const SizedBox(height: 15),
            FilledButton(
              onPressed: onNew,
              style: FilledButton.styleFrom(backgroundColor: kRed),
              child: const Text('Create essay'),
            ),
          ],
        ),
      );
}
