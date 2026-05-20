import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/queue_item_model.dart';

abstract class QueueEvent extends Equatable {
  @override List<Object?> get props => [];
}
class LoadQueueEvent extends QueueEvent {}
class RefreshQueueEvent extends QueueEvent {}
class UploadVideoEvent extends QueueEvent {
  final String videoPath, title, description;
  final List<String> platforms, hashtags;
  UploadVideoEvent({required this.videoPath, required this.title, required this.description, required this.platforms, required this.hashtags});
  @override List<Object?> get props => [videoPath, title, platforms];
}

abstract class QueueState extends Equatable {
  @override List<Object?> get props => [];
}
class QueueInitial extends QueueState {}
class QueueLoading extends QueueState {}
class QueueLoaded extends QueueState {
  final List<QueueItemModel> items;
  QueueLoaded(this.items);
  @override List<Object?> get props => [items];
}
class QueueError extends QueueState {
  final String message;
  QueueError(this.message);
  @override List<Object?> get props => [message];
}

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final ApiClient _api;
  // Demo items shown while backend isn't connected
  final List<QueueItemModel> _demoItems = [
    QueueItemModel(id: 'demo_1', title: 'AI Replaced My Entire Team', platform: 'YouTube Shorts', status: UploadStatus.uploading, progress: 0.73, createdAt: '2m ago', emoji: '🎬'),
    QueueItemModel(id: 'demo_2', title: 'Ancient Trick Doubles Your Memory', platform: 'TikTok', status: UploadStatus.processing, progress: 0.45, createdAt: '8m ago', emoji: '🧠'),
    QueueItemModel(id: 'demo_3', title: 'Why Rich People Sleep at 9PM', platform: 'Instagram Reels', status: UploadStatus.queued, progress: 0.0, createdAt: '15m ago', emoji: '💰'),
    QueueItemModel(id: 'demo_4', title: 'The Crypto Signal Nobody Sees', platform: 'YouTube Shorts', status: UploadStatus.published, progress: 1.0, createdAt: '1h ago', emoji: '📈'),
    QueueItemModel(id: 'demo_5', title: 'AI Predicted My Future', platform: 'TikTok', status: UploadStatus.published, progress: 1.0, createdAt: '3h ago', emoji: '👁️'),
    QueueItemModel(id: 'demo_6', title: 'They Hid This For 1000 Years', platform: 'Facebook Reels', status: UploadStatus.failed, progress: 0.0, createdAt: '4h ago', emoji: '🏛️'),
  ];

  QueueBloc(this._api) : super(QueueInitial()) {
    on<LoadQueueEvent>(_onLoad);
    on<RefreshQueueEvent>(_onRefresh);
    on<UploadVideoEvent>(_onUpload);
  }

  Future<void> _onLoad(LoadQueueEvent e, Emitter<QueueState> emit) async {
    emit(QueueLoading());
    await Future.delayed(const Duration(milliseconds: 800));
    emit(QueueLoaded(_demoItems));
  }

  Future<void> _onRefresh(RefreshQueueEvent e, Emitter<QueueState> emit) async {
    emit(QueueLoaded(_demoItems));
  }

  Future<void> _onUpload(UploadVideoEvent e, Emitter<QueueState> emit) async {
    try {
      await _api.queueUpload(
        videoPath: e.videoPath, platforms: e.platforms,
        title: e.title, description: e.description, hashtags: e.hashtags,
      );
      add(RefreshQueueEvent());
    } catch (err) {
      emit(QueueError('Upload failed: $err'));
    }
  }
}
