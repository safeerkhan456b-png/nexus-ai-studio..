import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_client.dart';

abstract class AnalyticsEvent extends Equatable {
  @override List<Object?> get props => [];
}
class RunAnalyticsEvent extends AnalyticsEvent {
  final String niche; final int days;
  RunAnalyticsEvent({this.niche = 'general', this.days = 28});
  @override List<Object?> get props => [niche, days];
}

abstract class AnalyticsState extends Equatable {
  @override List<Object?> get props => [];
}
class AnalyticsInitial extends AnalyticsState {}
class AnalyticsLoading extends AnalyticsState {}
class AnalyticsLoaded extends AnalyticsState {
  final Map<String, dynamic> data;
  AnalyticsLoaded(this.data);
  @override List<Object?> get props => [data];
}
class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError(this.message);
  @override List<Object?> get props => [message];
}

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final ApiClient _api;
  AnalyticsBloc(this._api) : super(AnalyticsInitial()) {
    on<RunAnalyticsEvent>(_onRun);
  }

  Future<void> _onRun(RunAnalyticsEvent e, Emitter<AnalyticsState> emit) async {
    emit(AnalyticsLoading());
    try {
      final result = await _api.runAnalytics(niche: e.niche, days: e.days);
      emit(AnalyticsLoaded(result));
    } catch (err) {
      emit(AnalyticsError('Analytics failed: $err'));
    }
  }
}
