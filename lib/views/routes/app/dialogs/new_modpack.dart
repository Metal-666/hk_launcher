import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hk_launcher/views/reusable/responsive_progress_ring.dart';

import '../../../../bloc/profiles/bloc.dart';
import '../../../../bloc/profiles/events.dart';
import '../../../../bloc/profiles/state.dart';

class NewModpackDialog extends StatefulWidget {
  final Profile profile;

  const NewModpackDialog(this.profile, {Key? key}) : super(key: key);

  @override
  State<NewModpackDialog> createState() => _NewModpackDialogState();
}

class _NewModpackDialogState extends State<NewModpackDialog> {
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProfilesBloc, ProfilesState>(
          builder: (context, state) => state.isNewModpackInitializing
              ? _newModpackProgress()
              : _newModpackInput(context, state));

  Widget _newModpackProgress() => const ResponsiveProgressRing();

  Widget _newModpackInput(BuildContext context, ProfilesState state) =>
      ContentDialog(
        title: Text(
            'New modpack (based on ${state.newModpack?.basedOn ?? 'ERROR'})'),
        content: TextFormBox(
          controller: nameController,
          autovalidateMode: AutovalidateMode.always,
          onChanged: (text) =>
              context.read<ProfilesBloc>().add(ChangeNewModpackName(text)),
          onFieldSubmitted: (_) => context
              .read<ProfilesBloc>()
              .add(SubmitNewModpackDialog(widget.profile, state.newModpack!)),
          validator: (_) => state.newModpack?.nameError,
          placeholder: 'Modpack name',
        ),
        actions: <Widget>[
          Button(
            child: const Text('Create'),
            onPressed: () => context
                .read<ProfilesBloc>()
                .add(SubmitNewModpackDialog(widget.profile, state.newModpack!)),
          ),
          Button(
            child: const Text('Cancel'),
            onPressed: () =>
                context.read<ProfilesBloc>().add(CloseNewModpackDialog()),
          )
        ],
      );

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }
}
