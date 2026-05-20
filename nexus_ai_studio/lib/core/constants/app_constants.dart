class AppConstants {
  // ─── Change this to your backend IP/domain ───────────────
  // Emulator: http://10.0.2.2:8000/api/v1
  // Real device (same WiFi): http://192.168.1.X:8000/api/v1
  // Production: https://api.yourdomain.com/api/v1
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 120);

  static const List<String> niches = [
    'ai', 'finance', 'motivation', 'horror', 'gaming',
    'facts', 'history', 'sports', 'tech', 'islamic', 'drama',
  ];

  static const List<String> platforms = [
    'youtube', 'tiktok', 'instagram', 'facebook',
  ];

  static const List<int> durations = [15, 30, 60, 90];

  static const List<String> languages = ['english', 'urdu', 'hindi'];

  static const List<String> tones = [
    'educational', 'dramatic', 'motivational', 'horror', 'casual', 'authoritative',
  ];

  static const Map<String, String> voiceOptions = {
    'english_male':   'Andrew — English Male',
    'english_female': 'Ava — English Female',
    'urdu_male':      'Asad — Urdu Male',
    'urdu_female':    'Uzma — Urdu Female',
    'hindi_male':     'Madhur — Hindi Male',
    'hindi_female':   'Swara — Hindi Female',
  };

  static const Map<String, String> nicheEmojis = {
    'ai':         '🤖',
    'finance':    '💰',
    'motivation': '💪',
    'horror':     '👻',
    'gaming':     '🎮',
    'facts':      '🧠',
    'history':    '🏛️',
    'sports':     '⚽',
    'tech':       '📱',
    'islamic':    '🕌',
    'drama':      '🎭',
  };

  static const Map<String, String> platformEmojis = {
    'youtube':   '▶️',
    'tiktok':    '🎵',
    'instagram': '📸',
    'facebook':  '👍',
  };
}
