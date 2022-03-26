import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import '../../../util/translations.dart';
import 'pages/saves.dart';

import '../../../bloc/main/bloc.dart';
import '../../../bloc/main/events.dart';
import '../../../bloc/main/state.dart';
import 'pages/profiles.dart';
import 'pages/settings.dart';

class AppPage extends StatelessWidget {
  const AppPage({Key? key}) : super(key: key);

  @override
  Widget build(context) => BlocBuilder<MainBloc, MainState>(
      builder: (context, state) => _navigationView(context, state));

  NavigationView _navigationView(BuildContext context, MainState state) =>
      NavigationView(
        appBar: NavigationAppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'HK LAUNCHER',
              style: FluentTheme.of(context).typography.title,
            ),
          ),
          automaticallyImplyLeading: false,
          actions: SizedBox.square(
            dimension: 50,
            child: IconButton(
              icon: const Icon(AntDesign.github, size: 32),
              onPressed: () => context.read<MainBloc>().add(OpenGitHub()),
            ),
          ),
        ),
        content: NavigationBody(
          index: state.navIndex,
          children: const <Widget>[
            ProfilesPage(),
            SavesPage(),
            SettingsPage(),
          ],
        ),
        pane: NavigationPane(
          // Glory to Ukraine :)
          header: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                tr([
                  'navigation_panel',
                  'warship-1',
                ]),
                style: TextStyle(color: Colors.blue),
                textAlign: TextAlign.center,
              ),
              Text(
                tr([
                  'navigation_panel',
                  'warship-2',
                ]),
                style: TextStyle(color: Colors.yellow.darkest),
                textAlign: TextAlign.center,
              )
            ],
          ),
          selected: state.navIndex,
          onChanged: (int index) =>
              context.read<MainBloc>().add(Navigate(index)),
          items: <NavigationPaneItem>[
            PaneItem(
              icon: const Icon(FluentIcons.project_collection),
              title: Text(tr([
                'navigation_panel',
                'profiles',
              ])),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.save),
              title: Text(tr([
                'navigation_panel',
                'saves',
              ])),
            ),
          ],
          footerItems: <NavigationPaneItem>[
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: Text(tr([
                'navigation_panel',
                'settings',
              ])),
            )
          ],
        ),
      );
}
