import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/wardrobe_provider.dart';
import '../../models/wardrobe_item.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});
  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: AppConstants.wardrobeCategories.length + 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<WardrobeProvider>().loadWardrobe());
  }

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WardrobeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wardrobe'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [
            const Tab(text: 'All'),
            ...AppConstants.wardrobeCategories.map((c) => Tab(text: c[0].toUpperCase() + c.substring(1))),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/wardrobe/add').then((_) =>
              context.read<WardrobeProvider>().loadWardrobe())),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _search,
            decoration: const InputDecoration(
              hintText: 'Search items...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => context.read<WardrobeProvider>().loadWardrobe(search: v),
          ),
        ),
        Expanded(
          child: wp.loading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _ItemGrid(items: wp.items),
                    ...AppConstants.wardrobeCategories.map((c) => _ItemGrid(items: wp.byCategory(c))),
                  ],
                ),
        ),
      ]),
    );
  }
}

class _ItemGrid extends StatelessWidget {
  final List<WardrobeItem> items;
  const _ItemGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.checkroom_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('No items yet', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => context.push('/wardrobe/add'),
            child: const Text('Add Item'),
          ),
        ]),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _WardrobeCard(item: items[i]),
    );
  }
}

class _WardrobeCard extends StatelessWidget {
  final WardrobeItem item;
  const _WardrobeCard({required this.item});

  String get _emoji {
    switch (item.category.toLowerCase()) {
      case 'tops': return '👕';
      case 'bottoms': return '👖';
      case 'footwear': return '👟';
      case 'accessories': return '⌚';
      case 'outerwear': return '🧥';
      default: return '👔';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: () => _showDeleteDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text(_emoji, style: const TextStyle(fontSize: 40))),
              const SizedBox(height: 8),
              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(item.category, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const Spacer(),
              Row(children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: _colorFromName(item.primaryColor),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(item.primaryColor, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
              ]),
              if (item.styleTags.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(item.styleTags.take(2).join(' · '), style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFromName(String name) {
    final map = <String, Color>{
      'white': Colors.white, 'black': Colors.black, 'grey': Colors.grey,
      'navy': const Color(0xFF001F5B), 'beige': const Color(0xFFF5F0DC),
      'brown': Colors.brown, 'blue': Colors.blue, 'red': Colors.red,
      'green': Colors.green, 'yellow': Colors.yellow, 'pink': Colors.pink,
      'purple': Colors.purple,
    };
    return map[name.toLowerCase()] ?? Colors.grey;
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Remove ${item.name}?'),
        content: const Text('This will remove the item from your wardrobe.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<WardrobeProvider>().deleteItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
