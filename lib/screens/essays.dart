import 'package:flutter/material.dart';
import '../main.dart';
import '../models/essay.dart';
import '../widgets/brand_header.dart';

class EssaysScreen extends StatefulWidget {
  final List<Essay> essays;
  final VoidCallback onNew;
  final ValueChanged<Essay> onOpen;
  final ValueChanged<Essay> onDelete;
  final ValueChanged<Essay> onFavorite;

  const EssaysScreen({
    super.key,
    required this.essays,
    required this.onNew,
    required this.onOpen,
    required this.onDelete,
    required this.onFavorite,
  });

  @override
  State<EssaysScreen> createState() => _EssaysScreenState();
}

class _EssaysScreenState extends State<EssaysScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.essays.where((e) {
      final q = query.toLowerCase();
      return e.title.toLowerCase().contains(q) || e.content.toLowerCase().contains(q);
    }).toList();

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: BrandHeader(
            title: 'Your essays',
            subtitle: 'Everything you write, in one place.',
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              TextField(
                onChanged: (v) => setState(() => query = v),
                decoration: const InputDecoration(
                  hintText: 'Search essays...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 18),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(child: Text('No essays found.')),
                )
              else
                ...filtered.map((essay) => Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        onTap: () => widget.onOpen(essay),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 5,
                        ),
                        title: Text(
                          essay.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          essay.content.trim().isEmpty ? 'Empty essay' : essay.content.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: const Icon(Icons.article_outlined, color: kRed),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'favorite') widget.onFavorite(essay);
                            if (v == 'delete') widget.onDelete(essay);
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'favorite',
                              child: Text(essay.favorite ? 'Unfavorite' : 'Favorite'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    )),
            ]),
          ),
        ),
      ],
    );
  }
}
