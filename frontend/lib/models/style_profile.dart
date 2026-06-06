class StyleProfile {
  final int id;
  final int userId;
  final double minimalistScore;
  final double oldMoneyScore;
  final double smartCasualScore;
  final double streetwearScore;
  final double formalScore;
  final double athleisureScore;
  final double vintageScore;
  final String lifestyle;
  final String budgetRange;
  final List<String> favoriteColors;
  final List<String> avoidedColors;
  final String fitPreference;
  final List<String> fashionGoals;
  final String dominantStyle;

  StyleProfile({
    required this.id,
    required this.userId,
    required this.minimalistScore,
    required this.oldMoneyScore,
    required this.smartCasualScore,
    required this.streetwearScore,
    required this.formalScore,
    required this.athleisureScore,
    required this.vintageScore,
    required this.lifestyle,
    required this.budgetRange,
    required this.favoriteColors,
    required this.avoidedColors,
    required this.fitPreference,
    required this.fashionGoals,
    required this.dominantStyle,
  });

  factory StyleProfile.fromJson(Map<String, dynamic> j) => StyleProfile(
        id: j['id'],
        userId: j['user_id'],
        minimalistScore: (j['minimalist_score'] as num).toDouble(),
        oldMoneyScore: (j['old_money_score'] as num).toDouble(),
        smartCasualScore: (j['smart_casual_score'] as num).toDouble(),
        streetwearScore: (j['streetwear_score'] as num).toDouble(),
        formalScore: (j['formal_score'] as num).toDouble(),
        athleisureScore: (j['athleisure_score'] as num).toDouble(),
        vintageScore: (j['vintage_score'] as num).toDouble(),
        lifestyle: j['lifestyle'] ?? '',
        budgetRange: j['budget_range'] ?? 'medium',
        favoriteColors: List<String>.from(j['favorite_colors'] ?? []),
        avoidedColors: List<String>.from(j['avoided_colors'] ?? []),
        fitPreference: j['fit_preference'] ?? 'regular',
        fashionGoals: List<String>.from(j['fashion_goals'] ?? []),
        dominantStyle: j['dominant_style'] ?? '',
      );

  Map<String, double> get allScores => {
        'Minimalist': minimalistScore,
        'Old Money': oldMoneyScore,
        'Smart Casual': smartCasualScore,
        'Streetwear': streetwearScore,
        'Formal': formalScore,
        'Athleisure': athleisureScore,
        'Vintage': vintageScore,
      };
}
