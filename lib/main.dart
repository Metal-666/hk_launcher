import 'dart:developer';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hk_launcher/util/converters.dart';
import 'package:system_theme/system_theme.dart';

import 'bloc/loading/bloc.dart';
import 'bloc/loading/state.dart';
import 'bloc/loading/events.dart';
import 'bloc/main/bloc.dart';
import 'bloc/main/events.dart';
import 'bloc/main/state.dart';
import 'data/settings/settings_repository.dart';
import 'views/routes/app/app.dart';
import 'views/routes/loading/loading.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => FluentApp(
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
    ),
    GoRoute(
      path: '/loading',
      builder: (context, state) => FluentApp(
        themeMode: ThemeMode.dark,
        darkTheme: _createTheme(darkMode: true),
        home: BlocProvider(
          create: (context) => LoadingBloc(context.read<SettingsRepository>()),
          child: const LoadingPage(),
        ),
      ),
    ),
  ],
);

ThemeData _createTheme({bool darkMode = false}) => ThemeData(
    brightness: darkMode ? Brightness.dark : Brightness.light,
    accentColor: SystemTheme.accentInstance.accent.toAccentColor());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemTheme.accentInstance.load();

  /*await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.acrylic,
    color: Colors.purple,
  );*/

  runApp(RepositoryProvider(
    create: (context) => SettingsRepository(),
    child: WidgetsApp.router(
      title: 'hk_launcher',
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      color: SystemTheme.accentInstance.accent.toAccentColor(),
    ),
  ));
}
