import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/main/bloc.dart';
import '../../../bloc/main/events.dart';
import '../../../bloc/main/state.dart';
import 'pages/profiles.dart';
import 'pages/settings.dart';

class AppPage extends StatelessWidget {
  const AppPage({Key? key}) : super(key: key);

  @override
  Widget build(context) => BlocBuilder<MainBloc, MainState>(
        builder: (context, state) => _navigationView(context, state),
      );

  NavigationView _navigationView(BuildContext context, MainState state) =>
      NavigationView(
          content: NavigationBody(
            index: state.navIndex,
            children: const <Widget>[ProfilesPage(), SettingsPage()],
          ),
          pane: NavigationPane(
              header: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  'HK LAUNCHER',
                  style: FluentTheme.of(context).typography.title,
                ),
              ),
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
