import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../providers/style_provider.dart';
import '../widgets/weather_widget.dart';
import '../widgets/outfit_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final rp = context.read<RecommendationProvider>();
    final sp = context.read<StyleProvider>();
    await Future.wait([
      rp.loadWeather('London'),
      sp.loadProfile(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final rp = context.watch<RecommendationProvider>();
    final sp = context.watch<StyleProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Hi, ${auth.user?.fullName.split(' ').first ?? 'there'} 👋'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.go('/profile')),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Weather widget
                if (rp.weather != null) WeatherWidget(weather: rp.weather!),
                const SizedBox(height: 16),

                // Today's outfit section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today's Outfit", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => rp.getRecommendation(location: 'London'),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (rp.loading)
                  const Center(child: CircularProgressIndicator())
                else if (rp.current != null)
                  OutfitCard(recommendation: rp.current!)
                else if (sp.profile == null)
                  _EmptyStateCard(
                    icon: Icons.style,
                    title: 'Complete your style quiz',
                    subtitle: 'Get personalized outfit recommendations',
                    action: 'Start Quiz',
                    onTap: () => context.go('/onboarding'),
                  )
                else
                  _EmptyStateCard(
                    icon: Icons.checkroom,
                    title: 'Add items to your wardrobe',
                    subtitle: 'We need your clothes to make recommendations',
                    action: 'Add Items',
                    onTap: () => context.go('/wardrobe'),
                  ),

                const SizedBox(height: 24),

                // Quick Actions
                Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QuickAction(icon: Icons.explore, label: 'Discover', onTap: () => context.go('/discover')),
                    _QuickAction(icon: Icons.chat, label: 'Stylist', onTap: () => context.go('/stylist')),
                    _QuickAction(icon: Icons.checkroom, label: 'Wardrobe', onTap: () => context.go('/wardrobe')),
                    _QuickAction(icon: Icons.calendar_month, label: 'Calendar', onTap: () => context.go('/calendar')),
                  ],
                ),

                if (sp.profile != null) ...[
                  const SizedBox(height: 24),
                  _StyleDNASnapshot(profile: sp.profile!),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, action;
  final VoidCallback onTap;
  const _EmptyStateCard({required this.icon, required this.title, required this.subtitle, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: onTap, child: Text(action)),
        ]),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ]),
      ),
    );
  }
}

class _StyleDNASnapshot extends StatelessWidget {
  final dynamic profile;
  const _StyleDNASnapshot({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.auto_awesome, size: 18),
              const SizedBox(width: 8),
              Text('Your Style DNA', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Text(
              profile.dominantStyle.isNotEmpty
                  ? '✨ ${profile.dominantStyle.replaceAll("_", " ").toUpperCase()}'
                  : 'Complete quiz to see your DNA',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (profile.favoriteColors.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: (profile.favoriteColors as List<String>).take(5).map((c) =>
                  Chip(label: Text(c, style: const TextStyle(fontSize: 11)), padding: EdgeInsets.zero)
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
