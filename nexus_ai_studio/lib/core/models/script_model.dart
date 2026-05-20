class ScriptSegment {
  final String type;
  final String text;
  final int durationSeconds;
  final String emotion;
  final String pace;

  const ScriptSegment({
    required this.type, required this.text,
    required this.durationSeconds, required this.emotion, required this.pace,
  });

  factory ScriptSegment.fromJson(Map<String, dynamic> json) => ScriptSegment(
    type: json['type'] as String? ?? '',
    text: json['text'] as String? ?? '',
    durationSeconds: json['duration_seconds'] as int? ?? 0,
    emotion: json['emotion'] as String? ?? '',
    pace: json['pace'] as String? ?? 'medium',
  );
}

class ScriptModel {
  final String title;
  final String hook;
  final String fullScript;
  final List<ScriptSegment> segments;
  final int wordCount;
  final int estimatedDuration;
  final String language;
  final String tone;
  final List<String> hashtags;
  final String thumbnailConcept;
  final List<String> titleOptions;
  final String description;
  final List<String> viralHooks;

  const ScriptModel({
    required this.title, required this.hook, required this.fullScript,
    required this.segments, required this.wordCount, required this.estimatedDuration,
    required this.language, required this.tone, required this.hashtags,
    required this.thumbnailConcept, required this.titleOptions,
    required this.description, required this.viralHooks,
  });

  factory ScriptModel.fromJson(Map<String, dynamic> json) => ScriptModel(
    title: json['title'] as String? ?? '',
    hook: json['hook'] as String? ?? '',
    fullScript: json['full_script'] as String? ?? '',
    segments: (json['segments'] as List?)
        ?.map((s) => ScriptSegment.fromJson(s as Map<String, dynamic>))
        .toList() ?? [],
    wordCount: json['word_count'] as int? ?? 0,
    estimatedDuration: json['estimated_duration'] as int? ?? 60,
    language: json['language'] as String? ?? 'english',
    tone: json['tone'] as String? ?? 'educational',
    hashtags: (json['hashtags'] as List?)?.cast<String>() ?? [],
    thumbnailConcept: json['thumbnail_concept'] as String? ?? '',
    titleOptions: (json['title_options'] as List?)?.cast<String>() ?? [],
    description: json['description'] as String? ?? '',
    viralHooks: (json['viral_hooks'] as List?)?.cast<String>() ?? [],
  );
}
