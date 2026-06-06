import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/style_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _evolution;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = context.read<StyleProvider>();
    await sp.loadProfile();
    final evo = await sp.getEvolution();
    setState(() => _evolution = evo);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sp = context.watch<StyleProvider>();
    final user = auth.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              context.go('/auth/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User header
          Center(
            child: Column(children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 32, color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(user?.fullName ?? '', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(user?.email ?? '', style: TextStyle(color: Colors.grey[600])),
            ]),
          ),
          const SizedBox(height: 24),

          // Style DNA card
          if (sp.profile != null) ...[
            _SectionHeader(title: 'Style DNA', icon: Icons.auto_awesome),
            const SizedBox(height: 12),
            _StyleDNACard(profile: sp.profile!),
            const SizedBox(height: 20),
          ],

          // Evolution card
          if (_evolution != null) ...[
            _SectionHeader(title: 'Style Evolution', icon: Icons.trending_up),
            const SizedBox(height: 12),
            _EvolutionCard(evolution: _evolution!),
            const SizedBox(height: 20),
          ],

          // Settings section
          _SectionHeader(title: 'Settings', icon: Icons.settings_outlined),
          const SizedBox(height: 12),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.quiz_outlined),
                title: const Text('Retake Style Quiz'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/onboarding'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text('Sign Out'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () async {
                  await auth.logout();
                  if (!context.mounted) return;
                  context.go('/auth/login');
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    ]);
  }
}

class _StyleDNACard extends StatelessWidget {
  final dynamic profile;
  const _StyleDNACard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final scores = profile.allScores as Map<String, double>;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.dominantStyle.toString().replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            ...scores.entries.where((e) => e.value > 0).map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                SizedBox(width: 100, child: Text(e.key, style: const TextStyle(fontSize: 12))),
                Expanded(
                  child: LinearProgressIndicator(
                    value: e.value,
                    backgroundColor: Colors.grey.shade200,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(e.value * 100).toInt()}%', style: const TextStyle(fontSize: 11)),
              ]),
            )),
            if ((profile.favoriteColors as List).isNotEmpty) ...[
              const Divider(),
              const Text('Favorite Colors', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: (profile.favoriteColors as List<String>).map((c) =>
                Chip(label: Text(c, style: const TextStyle(fontSize: 11)), padding: EdgeInsets.zero)
              ).toList()),
            ],
          ],
        ),
      ),
    );
  }
}

class _EvolutionCard extends StatelessWidget {
  final Map<String, dynamic> evolution;
  const _EvolutionCard({required this.evolution});

  @override
  Widget build(BuildContext context) {
    final insights = (evolution['monthly_insights'] as List?) ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: insights.isEmpty
              ? [const Text('Like more outfits to see your style evolution', style: TextStyle(color: Colors.grey))]
              : insights.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('✨ ', style: TextStyle(fontSize: 14)),
                    Expanded(child: Text(i.toString(), style: const TextStyle(fontSize: 13))),
                  ]),
                )).toList(),
        ),
      ),
    );
  }
}
