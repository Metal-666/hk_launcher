import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hk_launcher/bloc/saves/events.dart';

import '../../../../bloc/saves/bloc.dart';
import '../../../../bloc/saves/state.dart';

class SavesPage extends StatelessWidget {
  const SavesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider<SavesBloc>(
        create: (context) => SavesBloc(),
        child: BlocBuilder<SavesBloc, SavesState>(
          builder: (context, state) => ScaffoldPage.scrollable(
            padding: EdgeInsets.zero,
            header: const Mica(
              child: Padding(
                padding: EdgeInsets.only(top: 16),
                child: PageHeader(title: Text('Saves')),
              ),
            ),
            children: <Widget>[
              const SizedBox(height: 20),
              FilledButton(
                child: const Text('Open Location In Explorer'),
                onPressed: () =>
                    context.read<SavesBloc>().add(OpenLocationInExplorer()),
              ),
              _spacer(),
              FilledButton(
                child: const Text('Copy Location To Clipboard'),
                onPressed: () =>
                    context.read<SavesBloc>().add(CopyLocationToClipboard()),
              ),
              _spacer(),
              FilledButton(
                child: const Text('Backup'),
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
