enum UploadStatus { queued, processing, uploading, published, failed }

class QueueItemModel {
  final String id;
  final String title;
  final String platform;
  final UploadStatus status;
  final double progress;
  final String createdAt;
  final String? platformVideoId;
  final String? errorMessage;
  final String emoji;

  const QueueItemModel({
    required this.id, required this.title, required this.platform,
    required this.status, required this.progress, required this.createdAt,
    this.platformVideoId, this.errorMessage, required this.emoji,
  });

  factory QueueItemModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'queued';
    final status = UploadStatus.values.firstWhere(
      (s) => s.name == statusStr, orElse: () => UploadStatus.queued,
    );
    return QueueItemModel(
      id: json['task_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      platform: json['platform'] as String? ?? '',
      status: status,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String? ?? '',
      platformVideoId: json['platform_video_id'] as String?,
      errorMessage: json['error_message'] as String?,
      emoji: '🎬',
    );
  }
}
