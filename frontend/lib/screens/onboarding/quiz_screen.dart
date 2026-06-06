import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/style_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _step = 0;
  final _totalSteps = 6;

  // Quiz state
  final Map<String, int> _outfitRatings = {};
  String _lifestyle = 'student';
  String _socialFreq = 'occasionally';
  String _environment = 'campus';
  int _fashionImportance = 3;
  String _budget = 'medium';
  final List<String> _favColors = [];
  final List<String> _avoidColors = [];
  String _fit = 'regular';
  final List<String> _goals = [];

  final _outfits = [
    {'id': 't1', 'label': 'White tee + tailored trousers', 'emoji': '🤍', 'style': 'Minimalist'},
    {'id': 't2', 'label': 'Polo shirt + chinos + loafers', 'emoji': '🎿', 'style': 'Old Money'},
    {'id': 't3', 'label': 'Graphic hoodie + cargo pants', 'emoji': '🖤', 'style': 'Streetwear'},
    {'id': 't4', 'label': 'Slim suit + Oxford shoes', 'emoji': '🎩', 'style': 'Formal'},
    {'id': 't5', 'label': 'Track jacket + joggers', 'emoji': '🏃', 'style': 'Athleisure'},
    {'id': 't6', 'label': 'Denim jacket + mom jeans', 'emoji': '🌻', 'style': 'Vintage'},
  ];

  Future<void> _submit() async {
    final quizData = {
      'outfit_ratings': _outfitRatings,
      'lifestyle': _lifestyle,
      'social_frequency': _socialFreq,
      'daily_environment': _environment,
      'fashion_importance': _fashionImportance,
      'budget_range': _budget,
      'favorite_colors': _favColors,
      'avoided_colors': _avoidColors,
      'fit_preference': _fit,
      'fashion_goals': _goals,
    };
    final ok = await context.read<StyleProvider>().submitQuiz(quizData);
    if (!mounted) return;
    if (ok) {
      await context.read<AuthProvider>().refreshUser();
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = context.watch<StyleProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Style Quiz ${_step + 1}/$_totalSteps'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_step + 1) / _totalSteps),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(child: _buildStep()),
              const SizedBox(height: 16),
              Row(children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: style.loading ? null : () {
                      if (_step < _totalSteps - 1) {
                        setState(() => _step++);
                      } else {
                        _submit();
                      }
                    },
                    child: style.loading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : Text(_step < _totalSteps - 1 ? 'Next' : 'Finish'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildOutfitRatings();
      case 1: return _buildLifestyle();
      case 2: return _buildBudget();
      case 3: return _buildColors();
      case 4: return _buildFit();
      case 5: return _buildGoals();
      default: return const SizedBox();
    }
  }

  Widget _buildOutfitRatings() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Visual Style', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Rate each outfit honestly', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ..._outfits.map((outfit) => _OutfitRatingCard(
                outfit: outfit,
                rating: _outfitRatings[outfit['id']] ?? 0,
                onRate: (r) => setState(() => _outfitRatings[outfit['id'] as String] = r),
              )),
        ],
      ),
    );
  }

  Widget _buildLifestyle() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Lifestyle', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _RadioGroup(
            label: 'I am a',
            options: const {'student': 'Student', 'professional': 'Working Professional'},
            value: _lifestyle,
            onChanged: (v) => setState(() => _lifestyle = v),
          ),
          const SizedBox(height: 20),
          _RadioGroup(
            label: 'Social events',
            options: const {'rarely': 'Rarely', 'occasionally': 'Occasionally', 'frequently': 'Frequently'},
            value: _socialFreq,
            onChanged: (v) => setState(() => _socialFreq = v),
          ),
          const SizedBox(height: 20),
          _RadioGroup(
            label: 'Daily environment',
            options: const {'campus': 'Campus', 'office': 'Office', 'home': 'Work from Home', 'mixed': 'Mixed'},
            value: _environment,
            onChanged: (v) => setState(() => _environment = v),
          ),
          const SizedBox(height: 20),
          Text('Fashion importance: $_fashionImportance/5'),
          Slider(
            value: _fashionImportance.toDouble(),
            min: 1, max: 5, divisions: 4,
            label: '$_fashionImportance',
            onChanged: (v) => setState(() => _fashionImportance = v.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildBudget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shopping Budget', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Per clothing purchase on average', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        ...{
          'low': ('Budget Friendly', 'Under \$30 per item', Icons.savings_outlined),
          'medium': ('Mid Range', '\$30–\$100 per item', Icons.shopping_bag_outlined),
          'high': ('Premium', 'Over \$100 per item', Icons.diamond_outlined),
        }.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SelectionCard(
                title: e.value.$1,
                subtitle: e.value.$2,
                icon: e.value.$3,
                selected: _budget == e.key,
                onTap: () => setState(() => _budget = e.key),
              ),
            )),
      ],
    );
  }

  Widget _buildColors() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Color Preferences', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Favorite colors (tap to select)'),
          const SizedBox(height: 12),
          _ColorGrid(
            colors: AppConstants.colors,
            selected: _favColors,
            onToggle: (c) => setState(() => _favColors.contains(c) ? _favColors.remove(c) : _favColors.add(c)),
          ),
          const SizedBox(height: 20),
          const Text('Colors you avoid'),
          const SizedBox(height: 12),
          _ColorGrid(
            colors: AppConstants.colors,
            selected: _avoidColors,
            onToggle: (c) => setState(() => _avoidColors.contains(c) ? _avoidColors.remove(c) : _avoidColors.add(c)),
          ),
        ],
      ),
    );
  }

  Widget _buildFit() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fit Preference', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        ...{
          'slim': ('Slim Fit', 'Close to the body', Icons.straighten),
          'regular': ('Regular Fit', 'Classic comfortable cut', Icons.checkroom),
          'relaxed': ('Relaxed Fit', 'Loose and comfortable', Icons.air),
          'oversized': ('Oversized', 'Big and boxy', Icons.open_in_full),
        }.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SelectionCard(
                title: e.value.$1,
                subtitle: e.value.$2,
                icon: e.value.$3,
                selected: _fit == e.key,
                onTap: () => setState(() => _fit = e.key),
              ),
            )),
      ],
    );
  }

  Widget _buildGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fashion Goals', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Select all that apply', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: AppConstants.fashionGoals.map((goal) => CheckboxListTile(
              title: Text(goal),
              value: _goals.contains(goal),
              onChanged: (v) => setState(() => v! ? _goals.add(goal) : _goals.remove(goal)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _OutfitRatingCard extends StatelessWidget {
  final Map<String, dynamic> outfit;
  final int rating;
  final void Function(int) onRate;

  const _OutfitRatingCard({required this.outfit, required this.rating, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(outfit['emoji'] as String, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(outfit['style'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(outfit['label'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Row(
              children: [
                _RateBtn(icon: Icons.close, color: Colors.red, active: rating == -1, onTap: () => onRate(-1)),
                const SizedBox(width: 4),
                _RateBtn(icon: Icons.remove, color: Colors.orange, active: rating == 0, onTap: () => onRate(0)),
                const SizedBox(width: 4),
                _RateBtn(icon: Icons.favorite, color: Colors.green, active: rating == 1, onTap: () => onRate(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RateBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool active;
  final VoidCallback onTap;
  const _RateBtn({required this.icon, required this.color, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: active ? color : color.withOpacity(0.15),
        child: Icon(icon, size: 16, color: active ? Colors.white : color),
      ),
    );
  }
}

class _RadioGroup extends StatelessWidget {
  final String label;
  final Map<String, String> options;
  final String value;
  final void Function(String) onChanged;
  const _RadioGroup({required this.label, required this.options, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.entries.map((e) => FilterChip(
            label: Text(e.value),
            selected: value == e.key,
            onSelected: (_) => onChanged(e.key),
          )).toList(),
        ),
      ],
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SelectionCard({required this.title, required this.subtitle, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? cs.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? cs.primary : null),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  final List<String> colors, selected;
  final void Function(String) onToggle;
  const _ColorGrid({required this.colors, required this.selected, required this.onToggle});

  static const _colorMap = {
    'white': Colors.white, 'black': Colors.black, 'grey': Colors.grey,
    'navy': Color(0xFF001F5B), 'beige': Color(0xFFF5F0DC), 'brown': Colors.brown,
    'blue': Colors.blue, 'red': Colors.red, 'green': Colors.green,
    'yellow': Colors.yellow, 'pink': Colors.pink, 'purple': Colors.purple,
    'olive': Color(0xFF6B7A1E), 'cream': Color(0xFFFFFDD0), 'camel': Color(0xFFC19A6B),
    'burgundy': Color(0xFF800020), 'orange': Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: colors.map((c) {
        final isSelected = selected.contains(c);
        final color = _colorMap[c] ?? Colors.grey;
        return GestureDetector(
          onTap: () => onToggle(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
          ),
        );
      }).toList(),
    );
  }
}
