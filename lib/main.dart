import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/root/bloc.dart';
import 'bloc/root/events.dart';
import 'bloc/root/states.dart';

void main() => runApp(FluentApp(
      title: 'hk_launcher',
      theme: ThemeData(accentColor: Colors.purple, brightness: Brightness.dark),
      home: BlocProvider(
        create: (context) => RootBloc(),
        child: const Root(),
      ),
    ));

class Root extends StatelessWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<RootBloc, RootState>(
        builder: (context, state) => NavigationView(
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
                    context.read<RootBloc>().add(Navigate(index)),
                items: <NavigationPaneItem>[
                  PaneItem(
                      icon: const Icon(FluentIcons.project_collection),
                      title: const Text('Profiles'))
                ])),
      );
}
