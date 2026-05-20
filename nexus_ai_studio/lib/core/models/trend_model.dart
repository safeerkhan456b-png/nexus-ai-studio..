class TrendModel {
  final String title;
  final double viralScore;
  final String engagementPrediction;
  final List<String> hashtags;
  final String category;
  final String scriptAngle;
  final List<String> sources;

  const TrendModel({
    required this.title,
    required this.viralScore,
    required this.engagementPrediction,
    required this.hashtags,
    required this.category,
    required this.scriptAngle,
    required this.sources,
  });

  factory TrendModel.fromJson(Map<String, dynamic> json) => TrendModel(
    title: json['title'] as String? ?? '',
    viralScore: (json['viral_score'] as num?)?.toDouble() ?? 0,
    engagementPrediction: json['engagement_prediction'] as String? ?? 'medium',
    hashtags: (json['hashtags'] as List?)?.cast<String>() ?? [],
    category: json['category'] as String? ?? '',
    scriptAngle: json['script_angle'] as String? ?? '',
    sources: (json['sources'] as List?)?.cast<String>() ?? [],
  );
}
