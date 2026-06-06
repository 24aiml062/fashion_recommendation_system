import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/wardrobe_provider.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _notes = TextEditingController();
  String _category = 'tops';
  String _color = 'white';
  final List<String> _styles = [];
  final List<String> _seasons = [];
  final List<String> _occasions = [];

  @override
  void dispose() {
    _name.dispose(); _brand.dispose(); _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ok = await context.read<WardrobeProvider>().addItem({
      'name': _name.text.trim(),
      'category': _category,
      'primary_color': _color,
      'brand': _brand.text.trim(),
      'notes': _notes.text.trim(),
      'style_tags': _styles,
      'season_tags': _seasons,
      'occasion_tags': _occasions,
    });
    if (!mounted) return;
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WardrobeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Add to Wardrobe')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Item Name *', prefixIcon: Icon(Icons.label_outline)),
              validator: (v) => v!.isNotEmpty ? null : 'Required',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
              items: AppConstants.wardrobeCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c[0].toUpperCase() + c.substring(1))))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _color,
              decoration: const InputDecoration(labelText: 'Primary Color', prefixIcon: Icon(Icons.palette_outlined)),
              items: AppConstants.colors
                  .map((c) => DropdownMenuItem(value: c, child: Text(c[0].toUpperCase() + c.substring(1))))
                  .toList(),
              onChanged: (v) => setState(() => _color = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brand,
              decoration: const InputDecoration(labelText: 'Brand (optional)', prefixIcon: Icon(Icons.business_outlined)),
            ),
            const SizedBox(height: 20),
            _TagSection(
              label: 'Style Tags',
              options: AppConstants.styleCategories,
              selected: _styles,
              onToggle: (v) => setState(() => _styles.contains(v) ? _styles.remove(v) : _styles.add(v)),
            ),
            const SizedBox(height: 16),
            _TagSection(
              label: 'Season Tags',
              options: AppConstants.seasons,
              selected: _seasons,
              onToggle: (v) => setState(() => _seasons.contains(v) ? _seasons.remove(v) : _seasons.add(v)),
            ),
            const SizedBox(height: 16),
            _TagSection(
              label: 'Occasion Tags',
              options: AppConstants.occasions,
              selected: _occasions,
              onToggle: (v) => setState(() => _occasions.contains(v) ? _occasions.remove(v) : _occasions.add(v)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes (optional)', prefixIcon: Icon(Icons.note_outlined)),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: wp.loading ? null : _submit,
              child: wp.loading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('Add to Wardrobe'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagSection extends StatelessWidget {
  final String label;
  final List<String> options, selected;
  final void Function(String) onToggle;
  const _TagSection({required this.label, required this.options, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 4,
          children: options.map((o) => FilterChip(
            label: Text(o, style: const TextStyle(fontSize: 12)),
            selected: selected.contains(o),
            onSelected: (_) => onToggle(o),
          )).toList(),
        ),
      ],
    );
  }
}
