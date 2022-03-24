import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/saves/events.dart';

import '../../../../bloc/saves/bloc.dart';
import '../../../../bloc/saves/state.dart';
import '../../../../util/translations.dart';

class SavesPage extends StatelessWidget {
  const SavesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider<SavesBloc>(
        create: (context) => SavesBloc(),
        child: BlocBuilder<SavesBloc, SavesState>(
          builder: (context, state) => ScaffoldPage.scrollable(
            padding: EdgeInsets.zero,
            header: Mica(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: PageHeader(
                    title: Text(tr([
                  'navigation_panel',
                  'saves',
                ]))),
              ),
            ),
            children: <Widget>[
              const SizedBox(height: 20),
              FilledButton(
                child: Text(tr([
                  'pages',
                  'saves',
                  'open',
                ])),
                onPressed: () =>
                    context.read<SavesBloc>().add(OpenLocationInExplorer()),
              ),
              _spacer(),
              FilledButton(
                child: Text(tr([
                  'pages',
                  'saves',
                  'copy',
                ])),
                onPressed: () =>
                    context.read<SavesBloc>().add(CopyLocationToClipboard()),
              ),
              _spacer(),
              FilledButton(
                child: Text(tr([
                  'pages',
                  'saves',
                  'backup',
                ])),
                onPressed: state.backupCooldown
                    ? null
                    : () => context.read<SavesBloc>().add(Backup()),
              ),
            ],
          ),
        ),
      );

  Widget _spacer() => const SizedBox(height: 5);
}
