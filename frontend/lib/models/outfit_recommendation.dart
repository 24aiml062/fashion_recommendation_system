import 'wardrobe_item.dart';

class OutfitRecommendation {
  final int id;
  final WardrobeItem? top;
  final WardrobeItem? bottom;
  final WardrobeItem? footwear;
  final WardrobeItem? accessory;
  final WardrobeItem? outerwear;
  final double confidenceScore;
  final Map<String, dynamic> explanation;
  final String occasion;
  final Map<String, dynamic> weatherData;

  OutfitRecommendation({
    required this.id,
    this.top,
    this.bottom,
    this.footwear,
    this.accessory,
    this.outerwear,
    required this.confidenceScore,
    required this.explanation,
    required this.occasion,
    required this.weatherData,
  });

  factory OutfitRecommendation.fromJson(Map<String, dynamic> j) => OutfitRecommendation(
        id: j['id'],
        top: j['top'] != null ? WardrobeItem.fromJson(j['top']) : null,
        bottom: j['bottom'] != null ? WardrobeItem.fromJson(j['bottom']) : null,
        footwear: j['footwear'] != null ? WardrobeItem.fromJson(j['footwear']) : null,
        accessory: j['accessory'] != null ? WardrobeItem.fromJson(j['accessory']) : null,
        outerwear: j['outerwear'] != null ? WardrobeItem.fromJson(j['outerwear']) : null,
        confidenceScore: (j['confidence_score'] as num).toDouble(),
        explanation: Map<String, dynamic>.from(j['explanation'] ?? {}),
        occasion: j['occasion'] ?? '',
        weatherData: Map<String, dynamic>.from(j['weather_data'] ?? {}),
      );

  String get explanationSummary => explanation['summary'] ?? '';
  List<String> get reasons => List<String>.from(explanation['reasons'] ?? []);
}
