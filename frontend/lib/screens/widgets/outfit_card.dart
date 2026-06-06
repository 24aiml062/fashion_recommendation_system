import 'package:flutter/material.dart';
import '../../models/outfit_recommendation.dart';
import '../../models/wardrobe_item.dart';

class OutfitCard extends StatelessWidget {
  final OutfitRecommendation recommendation;
  const OutfitCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final rec = recommendation;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(rec.occasion.toUpperCase(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1)),
                _ConfidenceBadge(score: rec.confidenceScore),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (rec.top != null) _ItemChip(item: rec.top!),
                if (rec.bottom != null) _ItemChip(item: rec.bottom!),
                if (rec.footwear != null) _ItemChip(item: rec.footwear!),
              ],
            ),
            if (rec.accessory != null || rec.outerwear != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                if (rec.accessory != null) _ItemChip(item: rec.accessory!),
                if (rec.outerwear != null) _ItemChip(item: rec.outerwear!),
              ]),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
              const SizedBox(width: 6),
              Text('Why this works', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 6),
            Text(rec.explanationSummary, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ItemChip extends StatelessWidget {
  final WardrobeItem item;
  const _ItemChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(_categoryEmoji(item.category), style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(item.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  String _categoryEmoji(String cat) {
    switch (cat.toLowerCase()) {
      case 'tops': return '👕';
      case 'bottoms': return '👖';
      case 'footwear': return '👟';
      case 'accessories': return '⌚';
      case 'outerwear': return '🧥';
      default: return '👔';
    }
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double score;
  const _ConfidenceBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).toInt();
    final color = pct >= 70 ? Colors.green : pct >= 40 ? Colors.orange : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text('$pct% match', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
