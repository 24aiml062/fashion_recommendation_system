class WardrobeItem {
  final int id;
  final int userId;
  final String name;
  final String category;
  final String primaryColor;
  final List<String> styleTags;
  final List<String> seasonTags;
  final List<String> occasionTags;
  final String brand;
  final String notes;

  WardrobeItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.primaryColor,
    required this.styleTags,
    required this.seasonTags,
    required this.occasionTags,
    required this.brand,
    required this.notes,
  });

  factory WardrobeItem.fromJson(Map<String, dynamic> j) => WardrobeItem(
        id: j['id'],
        userId: j['user_id'],
        name: j['name'],
        category: j['category'],
        primaryColor: j['primary_color'],
        styleTags: List<String>.from(j['style_tags'] ?? []),
        seasonTags: List<String>.from(j['season_tags'] ?? []),
        occasionTags: List<String>.from(j['occasion_tags'] ?? []),
        brand: j['brand'] ?? '',
        notes: j['notes'] ?? '',
      );
}
