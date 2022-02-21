import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:system_theme/system_theme.dart';

import 'bloc/loading/bloc.dart';
import 'bloc/loading/state.dart';
import 'bloc/loading/events.dart';
import 'bloc/main/bloc.dart';
import 'bloc/main/events.dart';
import 'bloc/main/states.dart';
import 'data/settings/settings_repository.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (context) => MainBloc(context.read<SettingsRepository>()),
        child: const MainPage(),
      ),
    ),
    GoRoute(
      path: '/loading',
      builder: (context, state) => BlocProvider(
        create: (context) => LoadingBloc(context.read<SettingsRepository>()),
        child: const LoadingPage(),
      ),
    ),
  ],
);

ThemeData _createTheme(bool darkMode) => ThemeData(
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
    child: FluentApp.router(
      title: 'hk_launcher',
      themeMode: ThemeMode.system,
      theme: _createTheme(false),
      darkTheme: _createTheme(true),
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      color: SystemTheme.accentInstance.accent.toAccentColor(),
    ),
  ));
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(context) => BlocConsumer<MainBloc, MainState>(
        listener: (context, state) {
          if (!state.hkPathPresent) {
            showDialog(
              context: context,
              builder: (context) => ContentDialog(
                title: Text('No WiFi connection'),
                content: Text('Check your connection and try again'),
                actions: [
                  Button(
                      child: Text('Ok'),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              ),
            );
          }
        },
        builder: (context, state) => _navigationView(context, state),
      );

  NavigationView _navigationView(BuildContext context, MainState state) =>
      NavigationView(
          content: NavigationBody(
            index: state.navIndex,
            children: const <Widget>[
              ScaffoldPage(
                content: Text('lol1'),
              ),
              ScaffoldPage(
                content: Text('lol2'),
              )
            ],
          ),
          pane: NavigationPane(
              footerItems: <NavigationPaneItem>[
                PaneItem(
                    icon: const Icon(FluentIcons.settings),
                    title: const Text('Settings'))
              ],
              selected: state.navIndex,
              onChanged: (int index) =>
                  context.read<MainBloc>().add(Navigate(index)),
              items: <NavigationPaneItem>[
                PaneItem(
                    icon: const Icon(FluentIcons.project_collection),
                    title: const Text('Profiles'))
              ]));
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocListener<LoadingBloc, LoadingState>(
        listener: (context, state) {
          if (state.loaded) {
            GoRouter.of(context).go('/');
          }
        },
        child: CustomSingleChildLayout(
            delegate: LoadingPageProgressLayoutDelegate(fraction: 3),
            child: const ProgressRing()),
      );
}

class LoadingPageProgressLayoutDelegate extends SingleChildLayoutDelegate {
  Size? lastSize;
  int fraction;

  LoadingPageProgressLayoutDelegate({required this.fraction});

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double side = constraints.biggest.shortestSide / fraction;
    return BoxConstraints.expand(width: side, height: side);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
      (size.width / 2) - (childSize.width / 2),
      (size.height / 2) - (childSize.height / 2));

  @override
  Size getSize(BoxConstraints constraints) => lastSize = constraints.biggest;

  @override
  bool shouldRelayout(
          covariant LoadingPageProgressLayoutDelegate oldDelegate) =>
      oldDelegate.lastSize != lastSize;
}
