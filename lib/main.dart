import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/data/refresh/dataset_refresher.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_state.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

void main() {
  runApp(const ByTrainApp());
  // Silently refresh the timetable from the public sources after startup.
  // It runs in the background, respects a daily cooldown, and falls back to
  // the bundled dataset whenever anything fails — users never see this.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(DatasetRefresher().refreshIfStale());
  });
}

class ByTrainApp extends StatelessWidget {
  /// Tests pass a fresh router so each test starts from a clean navigation
  /// state (the default singleton retains its position across runs).
  final GoRouter? routerConfig;

  const ByTrainApp({super.key, this.routerConfig});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(create: (context) => SettingsBloc()),
        BlocProvider(create: (context) => HomeBloc()..add(LoadHomeData())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'ByTrain',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            routerConfig: routerConfig ?? AppRouter.router,
          );
        },
      ),
    );
  }
}
