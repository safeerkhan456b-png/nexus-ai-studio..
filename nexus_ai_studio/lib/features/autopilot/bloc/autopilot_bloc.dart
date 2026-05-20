import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_client.dart';

abstract class AutopilotEvent extends Equatable {
  @override List<Object?> get props => [];
}
class LoadAutopilotStatusEvent extends AutopilotEvent {}
class ToggleAutopilotEvent extends AutopilotEvent {
  final bool enabled;
  ToggleAutopilotEvent(this.enabled);
  @override List<Object?> get props => [enabled];
}
class UpdateAutopilotConfigEvent extends AutopilotEvent {
  final List<String> niches, platforms;
  final int dailyLimit, duration;
  final String language;
  UpdateAutopilotConfigEvent({required this.niches, required this.platforms, required this.dailyLimit, required this.duration, required this.language});
  @override List<Object?> get props => [niches, platforms, dailyLimit];
}
class RunAutopilotNowEvent extends AutopilotEvent {}

abstract class AutopilotState extends Equatable {
  @override List<Object?> get props => [];
}
class AutopilotInitial extends AutopilotState {}
class AutopilotLoading extends AutopilotState {}
class AutopilotActiveState extends AutopilotState {
  final int videosToday;
  final String? lastRun;
  final List<String> niches, platforms;
  final int dailyLimit, duration;
  final String language;
  AutopilotActiveState({this.videosToday = 0, this.lastRun, required this.niches, required this.platforms, required this.dailyLimit, required this.duration, required this.language});
  @override List<Object?> get props => [videosToday, lastRun, niches, platforms];
}
class AutopilotInactiveState extends AutopilotState {
  final List<String> niches, platforms;
  final int dailyLimit, duration;
  final String language;
  AutopilotInactiveState({required this.niches, required this.platforms, required this.dailyLimit, required this.duration, required this.language});
  @override List<Object?> get props => [niches, platforms, dailyLimit];
}
class AutopilotError extends AutopilotState {
  final String message;
  AutopilotError(this.message);
  @override List<Object?> get props => [message];
}

class AutopilotBloc extends Bloc<AutopilotEvent, AutopilotState> {
  final ApiClient _api;
  List<String> _niches = ['ai'];
  List<String> _platforms = ['youtube', 'tiktok'];
  int _dailyLimit = 3;
  int _duration = 60;
  String _language = 'english';

  AutopilotBloc(this._api) : super(AutopilotInitial()) {
    on<LoadAutopilotStatusEvent>(_onLoad);
    on<ToggleAutopilotEvent>(_onToggle);
    on<UpdateAutopilotConfigEvent>(_onUpdate);
    on<RunAutopilotNowEvent>(_onRunNow);
  }

  Future<void> _onLoad(LoadAutopilotStatusEvent e, Emitter<AutopilotState> emit) async {
    emit(AutopilotLoading());
    try {
      final status = await _api.getAutopilotStatus();
      final enabled = status['enabled'] as bool? ?? false;
      final args = (niches: _niches, platforms: _platforms, dailyLimit: _dailyLimit, duration: _duration, language: _language);
      if (enabled) {
        emit(AutopilotActiveState(videosToday: status['videos_created_today'] as int? ?? 0, lastRun: status['last_run'] as String?, niches: args.niches, platforms: args.platforms, dailyLimit: args.dailyLimit, duration: args.duration, language: args.language));
      } else {
        emit(AutopilotInactiveState(niches: args.niches, platforms: args.platforms, dailyLimit: args.dailyLimit, duration: args.duration, language: args.language));
      }
    } catch (_) {
      emit(AutopilotInactiveState(niches: _niches, platforms: _platforms, dailyLimit: _dailyLimit, duration: _duration, language: _language));
    }
  }

  Future<void> _onToggle(ToggleAutopilotEvent e, Emitter<AutopilotState> emit) async {
    emit(AutopilotLoading());
    try {
      await _api.configureAutopilot(niches: _niches, platforms: _platforms, dailyLimit: _dailyLimit, language: _language, duration: _duration, enabled: e.enabled);
      if (e.enabled) {
        emit(AutopilotActiveState(niches: _niches, platforms: _platforms, dailyLimit: _dailyLimit, duration: _duration, language: _language));
      } else {
        emit(AutopilotInactiveState(niches: _niches, platforms: _platforms, dailyLimit: _dailyLimit, duration: _duration, language: _language));
      }
    } catch (err) {
      emit(AutopilotError('Failed to toggle: $err'));
    }
  }

  Future<void> _onUpdate(UpdateAutopilotConfigEvent e, Emitter<AutopilotState> emit) async {
    _niches = e.niches; _platforms = e.platforms; _dailyLimit = e.dailyLimit; _duration = e.duration; _language = e.language;
    final isActive = state is AutopilotActiveState;
    if (isActive) {
      emit(AutopilotActiveState(niches: _niches, platforms: _platforms, dailyLimit: _dailyLimit, duration: _duration, language: _language));
    } else {
      emit(AutopilotInactiveState(niches: _niches, platforms: _platforms, dailyLimit: _dailyLimit, duration: _duration, language: _language));
    }
  }

  Future<void> _onRunNow(RunAutopilotNowEvent e, Emitter<AutopilotState> emit) async {
    try {
      await _api.runAutopilotNow({'niches': _niches, 'platforms': _platforms, 'daily_limit': _dailyLimit, 'language': _language, 'duration': _duration, 'enabled': true});
    } catch (err) {
      emit(AutopilotError('Run failed: $err'));
    }
  }
}
