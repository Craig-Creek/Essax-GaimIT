import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home.dart';
import 'screens/essays.dart';
import 'screens/editor.dart';
import 'screens/profile.dart';
import 'services/essay_storage.dart';
import 'models/essay.dart';

const kRed = Color(0xFFE53935);
const kOrange = Color(0xFFFF8A00);
const kInk = Color(0xFF171717);
const kMuted = Color(0xFF777777);
const kBackground = Color(0xFFF8F7F5);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EssaxApp());
}

class EssaxApp extends StatefulWidget {
  const EssaxApp({super.key});

  @override
  State<EssaxApp> createState() => _EssaxAppState();
}

class _EssaxAppState extends State<EssaxApp> {
  final storage = EssayStorage();
  List<Essay> essays = [];
  int tab = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await storage.load();
    if (mounted) setState(() { essays = data; loading = false; });
  }

  Future<void> _save() => storage.save(essays);

  void _upsert(Essay essay) {
    final i = essays.indexWhere((e) => e.id == essay.id);
    setState(() {
      if (i == -1) {
        essays.insert(0, essay);
      } else {
        essays[i] = essay;
      }
    });
    _save();
  }

  void _delete(Essay essay) {
    setState(() => essays.removeWhere((e) => e.id == essay.id));
    _save();
  }

  void _toggleFavorite(Essay essay) {
    essay.favorite = !essay.favorite;
    setState(() {});
    _save();
  }

  void _newEssay() {
    final essay = Essay(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: 'Untitled essay',
      content: '',
      updatedAt: DateTime.now(),
    );
    _upsert(essay);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EditorScreen(
        essay: essay,
        onChanged: _upsert,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: kBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kRed,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.lexendTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );

    final screens = [
      HomeScreen(
        essays: essays,
        onNew: _newEssay,
        onOpen: (e) => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => EditorScreen(essay: e, onChanged: _upsert),
        )),
        onFavorite: _toggleFavorite,
      ),
      EssaysScreen(
        essays: essays,
        onNew: _newEssay,
        onOpen: (e) => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => EditorScreen(essay: e, onChanged: _upsert),
        )),
        onDelete: _delete,
        onFavorite: _toggleFavorite,
      ),
      const ProfileScreen(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Essax',
      theme: theme,
      home: loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : Scaffold(
              body: IndexedStack(index: tab, children: screens),
              floatingActionButton: tab == 2
                  ? null
                  : FloatingActionButton.extended(
                      onPressed: _newEssay,
                      backgroundColor: kRed,
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('New essay'),
                    ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: tab,
                onDestinationSelected: (i) => setState(() => tab = i),
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xFFFFE1D5),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.description_outlined),
                    selectedIcon: Icon(Icons.description_rounded),
                    label: 'Essays',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
    );
  }
}
