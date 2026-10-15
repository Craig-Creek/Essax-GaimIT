import 'package:flutter/material.dart';

const Color kCanvas = Color(0xFF171310);
const Color kSurface = Color(0xFF241D18);
const Color kSurfaceRaised = Color(0xFF30251E);
const Color kBorder = Color(0xFF44352A);
const Color kOrange = Color(0xFFE87936);
const Color kOlive = Color(0xFF9A9D69);
const Color kCream = Color(0xFFF3E9DC);
const Color kMuted = Color(0xFFB7A99A);

void main() => runApp(const EssaxApp());

class EssaxApp extends StatelessWidget {
  const EssaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Essax',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kCanvas,
        colorScheme: const ColorScheme.dark(
          primary: kOrange,
          secondary: kOlive,
          surface: kSurface,
          onSurface: kCream,
        ),
        fontFamily: 'NovaSP',
        splashColor: kOrange.withValues(alpha: .08),
        highlightColor: Colors.transparent,
      ),
      home: const EssaxShell(),
    );
  }
}

class EssaxShell extends StatefulWidget {
  const EssaxShell({super.key});

  @override
  State<EssaxShell> createState() => _EssaxShellState();
}

class _EssaxShellState extends State<EssaxShell> {
  int _tab = 0;

  static const _pages = [
    EssaxHomePage(),
    CompetitionsPage(),
    DiscussionsPage(),
    TeamsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1D1713),
            border: Border(top: BorderSide(color: kBorder, width: .7)),
          ),
          padding: const EdgeInsets.fromLTRB(8, 9, 8, 7),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Home',
                selected: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
              _NavItem(
                icon: Icons.emoji_events_outlined,
                label: 'Competitions',
                selected: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
              _NavItem(
                icon: Icons.forum_outlined,
                label: 'Discussions',
                selected: _tab == 2,
                onTap: () => setState(() => _tab = 2),
              ),
              _NavItem(
                icon: Icons.groups_2_outlined,
                label: 'Teams',
                selected: _tab == 3,
                onTap: () => setState(() => _tab = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? kOrange.withValues(alpha: .13) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21, color: selected ? kOrange : kMuted),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? kCream : kMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EssaxHomePage extends StatelessWidget {
  const EssaxHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _TopBar(),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Eyebrow('YOUR SPACE TO BUILD'),
                const SizedBox(height: 8),
                const Text(
                  'Ideas grow\nbetter together.',
                  style: TextStyle(
                    color: kCream,
                    fontSize: 33,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.8,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Find your people. Take on challenges. Make something that matters.',
                  style: TextStyle(color: kMuted, height: 1.5, fontSize: 14),
                ),
                const SizedBox(height: 22),
                const _FeaturedCompetitionCard(),
                const SizedBox(height: 28),
                const _SectionHeading(
                  title: 'Pick up the conversation',
                  subtitle: 'Ideas being shared by the community',
                ),
                const SizedBox(height: 13),
                const _DiscussionPreview(
                  initials: 'AK',
                  name: 'Amina K.',
                  time: '12 min ago',
                  title: 'What makes a great team project?',
                  body: 'I think the best projects start with a problem people actually care about.',
                  tag: 'TEAMWORK',
                  replies: '8 replies',
                ),
                const SizedBox(height: 10),
                const _DiscussionPreview(
                  initials: 'TO',
                  name: 'Tobi O.',
                  time: '38 min ago',
                  title: 'Looking for a design partner',
                  body: 'I have an idea for a student productivity tool and need someone who enjoys UI design.',
                  tag: 'COLLABORATION',
                  replies: '5 replies',
                ),
                const SizedBox(height: 28),
                const _SectionHeading(
                  title: 'Find your crew',
                  subtitle: 'Small teams, ambitious ideas',
                ),
                const SizedBox(height: 13),
                const _TeamStrip(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 13, 20, 0),
        child: Row(
          children: [
            Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: kOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.all_inclusive_rounded, color: kCanvas, size: 24),
            ),
            const SizedBox(width: 10),
            const Text(
              'essax',
              style: TextStyle(
                color: kCream,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const Spacer(),
            _RoundAction(
              icon: Icons.search_rounded,
              onTap: () => _showMessage(context, 'Search is being prepared for the community.'),
            ),
            const SizedBox(width: 9),
            _RoundAction(
              icon: Icons.notifications_none_rounded,
              onTap: () => _showMessage(context, 'You’re all caught up. Notifications will appear here.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kSurface,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: kCream, size: 21),
        ),
      ),
    );
  }
}

class _FeaturedCompetitionCard extends StatelessWidget {
  const _FeaturedCompetitionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A2B1D), Color(0xFF2A2019), Color(0xFF26231A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF69412A).withValues(alpha: .7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kOrange.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'FEATURED CHALLENGE',
                  style: TextStyle(
                    color: Color(0xFFFFB37E),
                    fontSize: 9,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.north_east_rounded, color: kCream, size: 19),
            ],
          ),
          const SizedBox(height: 19),
          const Text(
            'Build for a\nbetter tomorrow.',
            style: TextStyle(
              color: kCream,
              fontSize: 25,
              height: 1.12,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'A community challenge for ideas that can make everyday life better.',
            style: TextStyle(color: Color(0xFFD4BFB0), fontSize: 12.5, height: 1.5),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: kOlive, size: 16),
              const SizedBox(width: 6),
              const Text('Open for applications', style: TextStyle(color: kCream, fontSize: 11)),
              const Spacer(),
              FilledButton(
                onPressed: () => _showMessage(
                  context,
                  'Competition applications will be enabled when Essax has its competition service connected.',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: kCanvas,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
                child: const Text('Explore', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: kCream, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -.3)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: kMuted, fontSize: 12.5)),
      ],
    );
  }
}

class _DiscussionPreview extends StatelessWidget {
  final String initials, name, time, title, body, tag, replies;
  const _DiscussionPreview({
    required this.initials,
    required this.name,
    required this.time,
    required this.title,
    required this.body,
    required this.tag,
    required this.replies,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: kBorder.withValues(alpha: .65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: kOlive.withValues(alpha: .22),
                child: Text(initials, style: const TextStyle(color: kCream, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 9),
              Text(name, style: const TextStyle(color: kCream, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(width: 7),
              Text('· $time', style: const TextStyle(color: kMuted, fontSize: 10.5)),
              const Spacer(),
              const Icon(Icons.more_horiz_rounded, color: kMuted, size: 20),
            ],
          ),
          const SizedBox(height: 13),
          Text(title, style: const TextStyle(color: kCream, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(body, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMuted, fontSize: 12.5, height: 1.45)),
          const SizedBox(height: 13),
          Row(
            children: [
              _Tag(tag),
              const Spacer(),
              const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: kOlive),
              const SizedBox(width: 5),
              Text(replies, style: const TextStyle(color: kMuted, fontSize: 10.5)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: kOlive.withValues(alpha: .12), borderRadius: BorderRadius.circular(7)),
      child: Text(text, style: const TextStyle(color: kOlive, fontSize: 8.5, letterSpacing: .8, fontWeight: FontWeight.w800)),
    );
  }
}

class _TeamStrip extends StatelessWidget {
  const _TeamStrip();

  @override
  Widget build(BuildContext context) {
    final teams = [
      ('M', 'Makers Lab', '4 members', const Color(0xFF9A9D69)),
      ('C', 'Code & Craft', '6 members', const Color(0xFFE87936)),
      ('F', 'Future Founders', '3 members', const Color(0xFFB67D91)),
    ];
    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: teams.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final team = teams[index];
          return Container(
            width: 142,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorder.withValues(alpha: .7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(color: team.$4.withValues(alpha: .2), borderRadius: BorderRadius.circular(11)),
                  child: Center(child: Text(team.$1, style: TextStyle(color: team.$4, fontWeight: FontWeight.w900, fontSize: 17))),
                ),
                const Spacer(),
                Text(team.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kCream, fontWeight: FontWeight.w800, fontSize: 12)),
                const SizedBox(height: 4),
                Text(team.$3, style: const TextStyle(color: kMuted, fontSize: 10.5)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CompetitionsPage extends StatelessWidget {
  const CompetitionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          const _PageHeader(kicker: 'TAKE ON A CHALLENGE', title: 'Competitions', subtitle: 'Put your ideas to the test, with a team or on your own.'),
          const SizedBox(height: 22),
          const _CompetitionCard(
            category: 'COMMUNITY IMPACT',
            title: 'Build for a better tomorrow',
            description: 'Design a useful solution to a real problem in your community.',
            status: 'Applications open',
            color: kOrange,
          ),
          const SizedBox(height: 12),
          const _CompetitionCard(
            category: 'CREATIVE TECHNOLOGY',
            title: 'The thoughtful tech sprint',
            description: 'Prototype a digital experience that makes a daily task easier.',
            status: 'Coming soon',
            color: kOlive,
          ),
          const SizedBox(height: 12),
          const _CompetitionCard(
            category: 'DESIGN & INNOVATION',
            title: 'Reimagine the everyday',
            description: 'Turn an overlooked frustration into a clear, testable concept.',
            status: 'Coming soon',
            color: Color(0xFFB67D91),
          ),
          const SizedBox(height: 14),
          const _InfoNote(text: 'These are starter examples for the interface. Live deadlines, eligibility, submissions and judging will need real competition data before launch.'),
        ],
      ),
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  final String category, title, description, status;
  final Color color;
  const _CompetitionCard({required this.category, required this.title, required this.description, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(22), border: Border.all(color: kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [_Tag(category), const Spacer(), Icon(Icons.arrow_outward_rounded, color: color, size: 18)]),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: kCream, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          Text(description, style: const TextStyle(color: kMuted, fontSize: 12.5, height: 1.5)),
          const SizedBox(height: 16),
          Row(children: [
            Icon(Icons.circle, size: 7, color: color),
            const SizedBox(width: 7),
            Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(
              onPressed: () => _showMessage(context, 'Competition details and applications will be connected to live data in a later step.'),
              child: const Text('View details'),
            ),
          ]),
        ],
      ),
    );
  }
}

class DiscussionsPage extends StatelessWidget {
  const DiscussionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          const _PageHeader(kicker: 'SHARE WHAT YOU’RE THINKING', title: 'Discussions', subtitle: 'Ask questions, share progress and find a new perspective.'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: kSurfaceRaised, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder)),
            child: Row(children: [
              const CircleAvatar(backgroundColor: kOlive, child: Icon(Icons.edit_rounded, color: kCanvas, size: 18)),
              const SizedBox(width: 11),
              const Expanded(child: Text('Start a thoughtful conversation…', style: TextStyle(color: kMuted, fontSize: 12.5))),
              IconButton(
                onPressed: () => _showMessage(context, 'Creating posts will be enabled after accounts and discussion storage are connected.'),
                icon: const Icon(Icons.add_circle_rounded, color: kOrange, size: 28),
              ),
            ]),
          ),
          const SizedBox(height: 19),
          const _DiscussionPreview(
            initials: 'AK', name: 'Amina K.', time: '12 min ago',
            title: 'What makes a great team project?',
            body: 'I think the best projects start with a problem people actually care about.',
            tag: 'TEAMWORK', replies: '8 replies',
          ),
          const SizedBox(height: 11),
          const _DiscussionPreview(
            initials: 'TO', name: 'Tobi O.', time: '38 min ago',
            title: 'Looking for a design partner',
            body: 'I have an idea for a student productivity tool and need someone who enjoys UI design.',
            tag: 'COLLABORATION', replies: '5 replies',
          ),
          const SizedBox(height: 11),
          const _DiscussionPreview(
            initials: 'FN', name: 'Farida N.', time: '1 hr ago',
            title: 'Share your progress this week',
            body: 'What is one small thing your team made progress on this week?',
            tag: 'WEEKLY CHECK-IN', replies: '12 replies',
          ),
          const SizedBox(height: 14),
          const _InfoNote(text: 'Sample discussions are shown for layout development; they are not live community posts yet.'),
        ],
      ),
    );
  }
}

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          const _PageHeader(kicker: 'BETTER WORK, TOGETHER', title: 'Teams', subtitle: 'Meet collaborators, build a crew and move an idea forward.'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF493021), Color(0xFF292019)]),
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: const Color(0xFF68432E)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.group_add_rounded, color: kOrange, size: 26),
              const SizedBox(height: 12),
              const Text('Good things rarely happen alone.', style: TextStyle(color: kCream, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              const Text('Create a team around a shared interest, or find people whose skills complement yours.', style: TextStyle(color: kMuted, fontSize: 12.5, height: 1.5)),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: () => _showMessage(context, 'Team creation and invitations will be enabled when user accounts and team storage are connected.'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Create a team'),
                  style: FilledButton.styleFrom(foregroundColor: kCream, backgroundColor: kOrange.withValues(alpha: .18)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          const _SectionHeading(title: 'Teams to discover', subtitle: 'A few examples of the communities Essax can support'),
          const SizedBox(height: 13),
          const _TeamRow(initial: 'M', name: 'Makers Lab', description: 'Turning everyday problems into useful prototypes.', members: '4 members', color: kOlive),
          const SizedBox(height: 10),
          const _TeamRow(initial: 'C', name: 'Code & Craft', description: 'A home for developers, designers and curious builders.', members: '6 members', color: kOrange),
          const SizedBox(height: 10),
          const _TeamRow(initial: 'F', name: 'Future Founders', description: 'Testing early ideas and learning by building.', members: '3 members', color: Color(0xFFB67D91)),
          const SizedBox(height: 14),
          const _InfoNote(text: 'Team names and member counts are placeholders until real teams and membership are connected.'),
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final String initial, name, description, members;
  final Color color;
  const _TeamRow({required this.initial, required this.name, required this.description, required this.members, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(19), border: Border.all(color: kBorder)),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: color.withValues(alpha: .17), borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(initial, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(color: kCream, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 4),
          Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kMuted, fontSize: 11.5, height: 1.4)),
          const SizedBox(height: 6),
          Text(members, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700)),
        ])),
        const SizedBox(width: 6),
        IconButton(
          onPressed: () => _showMessage(context, 'Team profiles and join requests will be connected in a later step.'),
          icon: const Icon(Icons.arrow_forward_ios_rounded, color: kMuted, size: 15),
        ),
      ]),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String kicker, title, subtitle;
  const _PageHeader({required this.kicker, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 13),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _TopBar(),
          const SizedBox(height: 26),
          _Eyebrow(kicker),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: kCream, fontSize: 31, fontWeight: FontWeight.w800, letterSpacing: -.7)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: kMuted, fontSize: 13, height: 1.5)),
        ]),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String text;
  const _Eyebrow(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(color: kOrange, fontSize: 9.5, letterSpacing: 1.6, fontWeight: FontWeight.w900),
      );
}

class _InfoNote extends StatelessWidget {
  final String text;
  const _InfoNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(15)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline_rounded, color: kOlive, size: 17),
        const SizedBox(width: 9),
        Expanded(child: Text(text, style: const TextStyle(color: kMuted, fontSize: 11, height: 1.5))),
      ]),
    );
  }
}

class _PageScaffold extends StatelessWidget {
  final Widget child;
  const _PageScaffold({required this.child});

  @override
  Widget build(BuildContext context) => ColoredBox(color: kCanvas, child: child);
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kSurfaceRaised,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
}
