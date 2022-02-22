import 'dart:developer';
import 'dart:io';

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
import 'bloc/main/state.dart';
import 'data/settings/settings_repository.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (context) =>
            MainBloc(context.read<SettingsRepository>())..add(AppLoaded()),
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
    child: FluentApp.router(
      title: 'hk_launcher',
      theme: _createTheme(),
      darkTheme: _createTheme(darkMode: true),
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
          if (state.hkPathDialog != null) {
            final TextEditingController pathController =
                TextEditingController();

            showDialog(
              context: context,
              builder: (_) => BlocProvider.value(
                value: context.read<MainBloc>(),
                child: ContentDialog(
                  title: const Text('Hollow Knight location'),
                  backgroundDismiss: false,
                  content: BlocConsumer<MainBloc, MainState>(
                    listener: (context, state) {
                      pathController.text = state.hkPathDialog!.path ?? '';
                    },
                    builder: (context, state) {
                      return Column(
                        children: <Widget>[
                          const Text(
                              'Please provide the path to the Hollow Knight directory.'),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: TextBox(controller: pathController),
                              ),
                              FilledButton(
                                  child: const Text('Browse'),
                                  onPressed: () => context
                                      .read<MainBloc>()
                                      .add(PickHKFolder()))
                            ],
                          ),
                          if (state.hkPathDialog!.error != null)
                            Text(state.hkPathDialog!.error!)
                        ],
                      );
                    },
                  ),
                  actions: [
                    Button(
                        child: const Text('Done'),
                        onPressed: () {
                          context
                              .read<MainBloc>()
                              .add(HKPathProvided(pathController.text));
                        }),
                    Button(
                        child: const Text('Exit'),
                        onPressed: () => context
                            .read<MainBloc>()
                            .add(HKPathDialogDismissed()))
                  ],
                ),
              ),
            );
          } else {
            Navigator.of(context).pop();
          }
        },
        listenWhen: (oldState, newState) =>
            (oldState.hkPathDialog == null) ^ (newState.hkPathDialog == null),
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
