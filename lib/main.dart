import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'util/converters.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_size/window_size.dart';

import 'bloc/loading/bloc.dart';
import 'bloc/main/bloc.dart';
import 'bloc/main/events.dart';
import 'data/settings/settings_repository.dart';
import 'views/routes/app/app.dart';
import 'views/routes/loading/loading.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: FluentApp(
          themeMode:
              themeModeConverter[context.read<SettingsRepository>().themeMode],
          theme: _createTheme(),
          darkTheme: _createTheme(darkMode: true),
          home: BlocProvider(
            create: (context) =>
                MainBloc(context.read<SettingsRepository>())..add(AppLoaded()),
            child: const AppPage(),
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/loading',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: FluentApp(
          themeMode: ThemeMode.dark,
          darkTheme: _createTheme(darkMode: true),
          home: BlocProvider(
            create: (context) =>
                LoadingBloc(context.read<SettingsRepository>()),
            child: const LoadingPage(),
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
  ],
);

ThemeData _createTheme({bool darkMode = false}) => ThemeData(
      brightness: darkMode ? Brightness.dark : Brightness.light,
      accentColor: SystemTheme.accentInstance.accent.toAccentColor(),
    );

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setWindowMinSize(const Size(384, 384));

  await SystemTheme.accentInstance.load();

  // Adds semi-transparent effect to the window. Unfortunately is currently broken on Windows 10. Hopefully this will be fixed in the future
  /*await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.acrylic,
    color: Colors.purple,
  );*/

  runApp(
    RepositoryProvider(
      create: (context) => SettingsRepository(),
      child: WidgetsApp.router(
        title: 'hk_launcher',
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        color: SystemTheme.accentInstance.accent.toAccentColor(),
      ),
    ),
  );
}
