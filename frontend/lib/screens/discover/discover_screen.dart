import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/style_provider.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<dynamic> _outfits = [];
  int _currentIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    try {
      final data = await context.read<StyleProvider>().loadTinderOutfits();
      setState(() { _outfits = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _swipe(String preference) async {
    if (_currentIndex >= _outfits.length) return;
    final outfit = _outfits[_currentIndex];
    await context.read<StyleProvider>().recordSwipe(
      outfit['id'] as String,
      preference,
      {'style': outfit['style'], 'colors': outfit['colors']},
    );
    setState(() => _currentIndex++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _currentIndex >= _outfits.length
              ? _buildDone()
              : _buildTinder(),
    );
  }

  Widget _buildTinder() {
    final outfit = _outfits[_currentIndex];
    final remaining = _outfits.length - _currentIndex;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Text('$remaining outfits left', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: _currentIndex / _outfits.length),
        const SizedBox(height: 24),
        Expanded(
          child: Card(
            elevation: 8,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(outfit['image_placeholder'] as String, style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 24),
                  Text(outfit['style'] as String,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(outfit['description'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: (outfit['colors'] as List).map((c) =>
                      Chip(label: Text(c.toString()), padding: EdgeInsets.zero)
                    ).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(outfit['occasion'] as String,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SwipeBtn(icon: Icons.close, color: Colors.red, label: 'Nope', onTap: () => _swipe('dislike')),
            _SwipeBtn(icon: Icons.bookmark_outline, color: Colors.blue, label: 'Save', onTap: () => _swipe('save')),
            _SwipeBtn(icon: Icons.favorite, color: Colors.green, label: 'Love it', onTap: () => _swipe('like')),
          ],
        ),
      ]),
    );
  }

  Widget _buildDone() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🎉', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        const Text('All caught up!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Your style profile has been updated'),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => setState(() { _currentIndex = 0; }),
          child: const Text('See them again'),
        ),
      ]),
    );
  }
}

class _SwipeBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _SwipeBtn({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        CircleAvatar(radius: 32, backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
