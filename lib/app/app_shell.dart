import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/home/home_screen.dart';
import '../features/competitions/competitions_screen.dart';
import '../features/discussions/discussions_screen.dart';
import '../features/teams/teams_screen.dart';
import 'app_theme.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CompetitionsScreen(),
    DiscussionsScreen(),
    TeamsScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSystemNavigationBar();
  }

  void _updateSystemNavigationBar() {
    final brightness = Theme.of(context).brightness;

    // Keep Android's system navigation area consistent with
    // Essax's bottom navigation bar in both themes.
    final Color navigationColor = brightness == Brightness.dark
        ? AppTheme.darkSurfaceColor
        : AppTheme.surfaceColor;

    final Color iconColor = brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: navigationColor,
        systemNavigationBarDividerColor: navigationColor,
        systemNavigationBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: brightness,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navigationColor = isDark
        ? AppTheme.darkSurfaceColor
        : AppTheme.surfaceColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: navigationColor,
        systemNavigationBarDividerColor: navigationColor,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          height: 82,
          selectedIndex: _selectedIndex,
          backgroundColor: navigationColor,
          indicatorColor: AppTheme.primaryColor.withValues(
            alpha: isDark ? 0.24 : 0.15,
          ),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events_rounded),
              label: 'Competitions',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              selectedIcon: Icon(Icons.forum_rounded),
              label: 'Discussions',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups_rounded),
              label: 'Teams',
            ),
          ],
        ),
      ),
    );
  }
}