import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/trend_model.dart';

// Events
abstract class TrendsEvent extends Equatable {
  @override List<Object?> get props => [];
}
class DiscoverTrendsEvent extends TrendsEvent {
  final String niche; final int limit;
  DiscoverTrendsEvent({required this.niche, this.limit = 10});
  @override List<Object?> get props => [niche, limit];
}
class SelectTrendEvent extends TrendsEvent {
  final TrendModel trend;
  SelectTrendEvent(this.trend);
  @override List<Object?> get props => [trend];
}

// States
abstract class TrendsState extends Equatable {
  @override List<Object?> get props => [];
}
class TrendsInitial extends TrendsState {}
class TrendsLoading extends TrendsState {
  final String niche;
  TrendsLoading(this.niche);
  @override List<Object?> get props => [niche];
}
class TrendsLoaded extends TrendsState {
  final List<TrendModel> trends;
  final String niche;
  final TrendModel? selected;
  TrendsLoaded({required this.trends, required this.niche, this.selected});
  @override List<Object?> get props => [trends, niche, selected];
}
class TrendsError extends TrendsState {
  final String message;
  TrendsError(this.message);
  @override List<Object?> get props => [message];
}

// BLoC
class TrendsBloc extends Bloc<TrendsEvent, TrendsState> {
  final ApiClient _api;
  TrendsBloc(this._api) : super(TrendsInitial()) {
    on<DiscoverTrendsEvent>(_onDiscover);
    on<SelectTrendEvent>(_onSelect);
  }

  Future<void> _onDiscover(DiscoverTrendsEvent e, Emitter<TrendsState> emit) async {
    emit(TrendsLoading(e.niche));
    try {
      final result = await _api.discoverTrends(e.niche, limit: e.limit);
      final trends = (result['trends'] as List)
          .map((t) => TrendModel.fromJson(t as Map<String, dynamic>))
          .toList();
      emit(TrendsLoaded(trends: trends, niche: e.niche));
    } catch (err) {
      emit(TrendsError('Failed to discover trends: $err'));
    }
  }

  void _onSelect(SelectTrendEvent e, Emitter<TrendsState> emit) {
    final cur = state;
    if (cur is TrendsLoaded) {
      emit(TrendsLoaded(trends: cur.trends, niche: cur.niche, selected: e.trend));
    }
  }
}
