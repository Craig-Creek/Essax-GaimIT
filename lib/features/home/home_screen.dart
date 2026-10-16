import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/app_theme.dart';
import '../../core/supabase_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCheckingConnection = false;
  bool? _connectionAvailable;
  String? _connectionMessage;

  Future<void> _checkConnection() async {
    setState(() {
      _isCheckingConnection = true;
      _connectionMessage = null;
    });

    try {
      // Accessing the client confirms that initialization completed.
      // A lightweight Auth request checks whether the Supabase endpoint
      // can be reached without requiring a database table.
      await supabase.auth.getSession();

      if (!mounted) return;

      setState(() {
        _connectionAvailable = true;
        _connectionMessage = 'Supabase client is responding.';
      });
    } on AuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _connectionAvailable = false;
        _connectionMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _connectionAvailable = false;
        _connectionMessage =
            'Unable to check the connection. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingConnection = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _checkConnection,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(theme),
                    const SizedBox(height: 28),
                    _buildWelcomeCard(theme, colors),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      title: 'Your community',
                      subtitle: 'Everything happening in Essax',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      context,
                      icon: Icons.emoji_events_rounded,
                      title: 'Competitions',
                      description:
                          'Discover challenges and opportunities to compete.',
                      accent: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      context,
                      icon: Icons.forum_rounded,
                      title: 'Discussions',
                      description:
                          'Share ideas and connect with the community.',
                      accent: AppTheme.secondaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      context,
                      icon: Icons.groups_rounded,
                      title: 'Teams',
                      description:
                          'Find your people and build something together.',
                      accent: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      title: 'Connection status',
                      subtitle: 'Check your Essax backend connection',
                    ),
                    const SizedBox(height: 16),
                    _buildConnectionCard(theme, colors),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'ESSAX  •  BY GAIMIT LLC',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.5,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.hub_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ESSAX',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Connect. Compete. Grow.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Check Supabase connection',
          onPressed: _isCheckingConnection ? null : _checkConnection,
          icon: const Icon(Icons.sync_rounded),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(ThemeData theme, ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF25231F)
            : const Color(0xFFF0E8DB),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'YOUR SPACE TO GROW',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFFD2D3A2)
                    : const Color(0xFF666A3D),
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Big things happen together.',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Discover competitions, exchange ideas, and find '
            'the right team to bring your next idea to life.',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.55,
              color: theme.colorScheme.onSurface
                  .withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your next opportunity starts here.',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface
                .withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color accent,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: colors.onSurface.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(
    ThemeData theme,
    ColorScheme colors,
  ) {
    final Color statusColor = _connectionAvailable == true
        ? Colors.green
        : _connectionAvailable == false
            ? colors.error
            : colors.onSurface.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _connectionAvailable == true
                    ? Icons.check_circle_rounded
                    : _connectionAvailable == false
                        ? Icons.error_outline_rounded
                        : Icons.cloud_outlined,
                color: statusColor,
                size: 25,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _connectionAvailable == true
                      ? 'Connection check completed'
                      : _connectionAvailable == false
                          ? 'Connection check failed'
                          : 'Supabase connection',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_isCheckingConnection)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
          if (_connectionMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _connectionMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Check whether the configured Supabase client responds.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  _isCheckingConnection ? null : _checkConnection,
              icon: const Icon(Icons.sync_rounded),
              label: Text(
                _isCheckingConnection
                    ? 'Checking...'
                    : 'Check connection',
              ),
            ),
          ),
        ],
      ),
    );
  }
}