import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/script_model.dart';

// Events
abstract class StudioEvent extends Equatable {
  @override List<Object?> get props => [];
}
class GenerateScriptEvent extends StudioEvent {
  final String topic, niche, language, tone;
  final int duration;
  final String? scriptAngle;
  GenerateScriptEvent({required this.topic, required this.niche, this.duration = 60, this.language = 'english', this.tone = 'educational', this.scriptAngle});
  @override List<Object?> get props => [topic, niche, duration, language, tone];
}
class GenerateVoiceoverEvent extends StudioEvent {
  final String scriptText, voice;
  GenerateVoiceoverEvent({required this.scriptText, this.voice = 'english_male'});
  @override List<Object?> get props => [scriptText, voice];
}
class CreateVideoEvent extends StudioEvent {
  final String script, voiceoverPath, niche;
  final int duration;
  CreateVideoEvent({required this.script, required this.voiceoverPath, required this.niche, required this.duration});
  @override List<Object?> get props => [script, voiceoverPath];
}
class PollVideoStatusEvent extends StudioEvent {
  final String jobId;
  PollVideoStatusEvent(this.jobId);
  @override List<Object?> get props => [jobId];
}
class ResetStudioEvent extends StudioEvent {}

// States
abstract class StudioState extends Equatable {
  @override List<Object?> get props => [];
}
class StudioInitial extends StudioState {}
class StudioGenerating extends StudioState {
  final String stage; // script | voiceover | video
  StudioGenerating(this.stage);
  @override List<Object?> get props => [stage];
}
class ScriptReady extends StudioState {
  final ScriptModel script;
  ScriptReady(this.script);
  @override List<Object?> get props => [script];
}
class VoiceoverReady extends StudioState {
  final ScriptModel script;
  final String audioPath;
  VoiceoverReady({required this.script, required this.audioPath});
  @override List<Object?> get props => [script, audioPath];
}
class VideoAssembling extends StudioState {
  final String jobId;
  final double progress;
  VideoAssembling({required this.jobId, this.progress = 0.0});
  @override List<Object?> get props => [jobId, progress];
}
class VideoReady extends StudioState {
  final String jobId, videoPath;
  VideoReady({required this.jobId, required this.videoPath});
  @override List<Object?> get props => [jobId, videoPath];
}
class StudioError extends StudioState {
  final String message, stage;
  StudioError({required this.message, required this.stage});
  @override List<Object?> get props => [message, stage];
}

// BLoC
class StudioBloc extends Bloc<StudioEvent, StudioState> {
  final ApiClient _api;
  ScriptModel? _currentScript;
  String? _currentAudioPath;

  StudioBloc(this._api) : super(StudioInitial()) {
    on<GenerateScriptEvent>(_onGenerateScript);
    on<GenerateVoiceoverEvent>(_onGenerateVoiceover);
    on<CreateVideoEvent>(_onCreateVideo);
    on<PollVideoStatusEvent>(_onPollStatus);
    on<ResetStudioEvent>((_, emit) { _currentScript = null; _currentAudioPath = null; emit(StudioInitial()); });
  }

  Future<void> _onGenerateScript(GenerateScriptEvent e, Emitter<StudioState> emit) async {
    emit(StudioGenerating('script'));
    try {
      final result = await _api.generateScript(topic: e.topic, niche: e.niche, duration: e.duration, language: e.language, tone: e.tone, scriptAngle: e.scriptAngle);
      _currentScript = ScriptModel.fromJson(result['script'] as Map<String, dynamic>);
      emit(ScriptReady(_currentScript!));
    } catch (err) {
      emit(StudioError(message: 'Script generation failed: $err', stage: 'script'));
    }
  }

  Future<void> _onGenerateVoiceover(GenerateVoiceoverEvent e, Emitter<StudioState> emit) async {
    emit(StudioGenerating('voiceover'));
    try {
      final result = await _api.generateVoiceover(text: e.scriptText, voice: e.voice);
      _currentAudioPath = result['audio_path'] as String;
      emit(VoiceoverReady(script: _currentScript!, audioPath: _currentAudioPath!));
    } catch (err) {
      emit(StudioError(message: 'Voiceover generation failed: $err', stage: 'voiceover'));
    }
  }

  Future<void> _onCreateVideo(CreateVideoEvent e, Emitter<StudioState> emit) async {
    emit(StudioGenerating('video'));
    try {
      final result = await _api.createVideo(script: e.script, voiceoverPath: e.voiceoverPath, duration: e.duration, niche: e.niche);
      final jobId = result['job_id'] as String;
      emit(VideoAssembling(jobId: jobId, progress: 0.0));
      add(PollVideoStatusEvent(jobId));
    } catch (err) {
      emit(StudioError(message: 'Video creation failed: $err', stage: 'video'));
    }
  }

  Future<void> _onPollStatus(PollVideoStatusEvent e, Emitter<StudioState> emit) async {
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      try {
        final status = await _api.getVideoStatus(e.jobId);
        final st = status['status'] as String;
        final progress = (status['progress'] as num?)?.toDouble() ?? 0.0;
        if (st == 'completed') {
          emit(VideoReady(jobId: e.jobId, videoPath: status['output_path'] as String? ?? ''));
          break;
        } else if (st == 'failed') {
          emit(StudioError(message: status['error'] as String? ?? 'Video assembly failed', stage: 'video'));
          break;
        } else {
          emit(VideoAssembling(jobId: e.jobId, progress: progress));
        }
      } catch (_) {}
    }
  }
}
