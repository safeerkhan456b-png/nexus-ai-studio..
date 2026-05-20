import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/pages/main_shell.dart';
import 'features/trends/bloc/trends_bloc.dart';
import 'features/studio/bloc/studio_bloc.dart';
import 'features/queue/bloc/queue_bloc.dart';
import 'features/analytics/bloc/analytics_bloc.dart';
import 'features/autopilot/bloc/autopilot_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF060B14),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await initDependencies();
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.I<TrendsBloc>()),
        BlocProvider(create: (_) => GetIt.I<StudioBloc>()),
        BlocProvider(create: (_) => GetIt.I<QueueBloc>()..add(LoadQueueEvent())),
        BlocProvider(create: (_) => GetIt.I<AnalyticsBloc>()),
        BlocProvider(create: (_) => GetIt.I<AutopilotBloc>()..add(LoadAutopilotStatusEvent())),
      ],
      child: MaterialApp(
        title: 'Nexus AI Studio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainShell(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        ),
      ),
    );
  }
}
