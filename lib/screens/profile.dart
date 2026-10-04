import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/brand_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: BrandHeader(
            title: 'Profile',
            subtitle: 'Your Essax writing space.',
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFFFE2D8),
                      child: Icon(Icons.person_rounded, color: kRed, size: 30),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Writer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('Keep building your ideas.', style: TextStyle(color: kMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Setting(icon: Icons.palette_outlined, title: 'Essax theme', value: 'Red → Orange'),
              _Setting(icon: Icons.storage_outlined, title: 'Storage', value: 'On this device'),
              _Setting(icon: Icons.info_outline_rounded, title: 'About Essax', value: 'Version 2.0.0'),
            ]),
          ),
        ),
      ],
    );
  }
}

class _Setting extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _Setting({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          leading: Icon(icon, color: kRed),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(value),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      );
}
