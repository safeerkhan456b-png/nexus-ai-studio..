import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  // ─── Trends ──────────────────────────────────────────────
  Future<Map<String, dynamic>> discoverTrends(String niche, {int limit = 10}) async {
    final r = await _dio.post('/trends/discover', data: {'niche': niche, 'limit': limit});
    return r.data as Map<String, dynamic>;
  }

  // ─── Scripts ─────────────────────────────────────────────
  Future<Map<String, dynamic>> generateScript({
    required String topic, required String niche,
    int duration = 60, String language = 'english',
    String tone = 'educational', String? scriptAngle,
  }) async {
    final r = await _dio.post('/scripts/generate', data: {
      'topic': topic, 'niche': niche, 'duration': duration,
      'language': language, 'tone': tone,
      if (scriptAngle != null) 'script_angle': scriptAngle,
    });
    return r.data as Map<String, dynamic>;
  }

  // ─── Voiceover ───────────────────────────────────────────
  Future<Map<String, dynamic>> generateVoiceover({
    required String text, String voice = 'english_male', double speed = 1.0,
  }) async {
    final r = await _dio.post('/voiceover/generate',
        data: {'text': text, 'voice': voice, 'speed': speed});
    return r.data as Map<String, dynamic>;
  }

  // ─── Video ───────────────────────────────────────────────
  Future<Map<String, dynamic>> createVideo({
    required String script, required String voiceoverPath,
    int duration = 60, String niche = 'general',
  }) async {
    final r = await _dio.post('/video/create', data: {
      'script': script, 'voiceover_path': voiceoverPath,
      'duration': duration, 'niche': niche,
    });
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getVideoStatus(String jobId) async {
    final r = await _dio.get('/video/status/$jobId');
    return r.data as Map<String, dynamic>;
  }

  // ─── Upload ──────────────────────────────────────────────
  Future<Map<String, dynamic>> queueUpload({
    required String videoPath, required List<String> platforms,
    required String title, required String description,
    required List<String> hashtags, String? thumbnailPath,
  }) async {
    final r = await _dio.post('/upload/queue', data: {
      'video_path': videoPath, 'platforms': platforms,
      'title': title, 'description': description, 'hashtags': hashtags,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
    });
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getUploadStatus(String taskId) async {
    final r = await _dio.get('/upload/status/$taskId');
    return r.data as Map<String, dynamic>;
  }

  // ─── Analytics ───────────────────────────────────────────
  Future<Map<String, dynamic>> runAnalytics({String niche = 'general', int days = 28}) async {
    final r = await _dio.post('/analytics/run', queryParameters: {'niche': niche, 'days': days});
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMemoryStats(String niche) async {
    final r = await _dio.get('/analytics/memory/$niche');
    return r.data as Map<String, dynamic>;
  }

  // ─── Autopilot ───────────────────────────────────────────
  Future<Map<String, dynamic>> configureAutopilot({
    required List<String> niches, required List<String> platforms,
    int dailyLimit = 3, String language = 'english', int duration = 60, bool enabled = true,
  }) async {
    final r = await _dio.post('/autopilot/configure', data: {
      'niches': niches, 'platforms': platforms,
      'daily_limit': dailyLimit, 'language': language,
      'duration': duration, 'enabled': enabled,
    });
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAutopilotStatus() async {
    final r = await _dio.get('/autopilot/status');
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> runAutopilotNow(Map<String, dynamic> config) async {
    final r = await _dio.post('/autopilot/run-now', data: config);
    return r.data as Map<String, dynamic>;
  }

  // ─── Auth ────────────────────────────────────────────────
  Future<Map<String, dynamic>> getAuthStatus() async {
    final r = await _dio.get('/auth/status');
    return r.data as Map<String, dynamic>;
  }
}
