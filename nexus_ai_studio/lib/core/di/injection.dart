import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../../features/trends/bloc/trends_bloc.dart';
import '../../features/studio/bloc/studio_bloc.dart';
import '../../features/queue/bloc/queue_bloc.dart';
import '../../features/analytics/bloc/analytics_bloc.dart';
import '../../features/autopilot/bloc/autopilot_bloc.dart';

Future<void> initDependencies() async {
  final sl = GetIt.I;
  sl.registerLazySingleton<ApiClient>(() => ApiClient.instance);
  sl.registerFactory<TrendsBloc>(() => TrendsBloc(sl<ApiClient>()));
  sl.registerFactory<StudioBloc>(() => StudioBloc(sl<ApiClient>()));
  sl.registerFactory<QueueBloc>(() => QueueBloc(sl<ApiClient>()));
  sl.registerFactory<AnalyticsBloc>(() => AnalyticsBloc(sl<ApiClient>()));
  sl.registerFactory<AutopilotBloc>(() => AutopilotBloc(sl<ApiClient>()));
}
