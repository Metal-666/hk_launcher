import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../util/translations.dart';
import '../../../reusable/responsive_progress_ring.dart';

import '../../../../bloc/profiles/bloc.dart';
import '../../../../bloc/profiles/events.dart';
import '../../../../bloc/profiles/state.dart';

// Shown on screen when duplicating a modpack
class NewModpackDialog extends StatefulWidget {
  final Profile profile;

  const NewModpackDialog(this.profile, {Key? key}) : super(key: key);

  @override
  State<NewModpackDialog> createState() => _NewModpackDialogState();
}

// Really hate to make this a stateful widget, but I don't see another way around. Basically I have to use TextEditingController to manage a TextBox's state (event though its text is already stored inside bloc's state... uhh...) and it needs to be disposed (only stateful widgets can do this)
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
        title: Text(tr([
              'dialogs',
              'new_modpack',
              'title',
              'new_modpack',
            ]) +
            '(' +
            tr([
              'dialogs',
              'new_modpack',
              'title',
              'based_on',
            ]) +
            (state.newModpack?.basedOn ??
                tr([
                  'errors',
                  'just_error',
                ])) +
            ')'),
        content: TextFormBox(
          controller: nameController,
          autovalidateMode: AutovalidateMode.always,
          onChanged: (text) =>
              context.read<ProfilesBloc>().add(ChangeNewModpackName(text)),
          onFieldSubmitted: (_) =>
              context.read<ProfilesBloc>().add(SubmitNewModpackDialog(
                    widget.profile,
                    state.newModpack!,
                  )),
          validator: (_) => state.newModpack?.nameError,
          placeholder: tr([
            'dialogs',
            'new_modpack',
            'content',
            'form',
            'name',
            'placeholder',
          ]),
        ),
        actions: <Widget>[
          Button(
            child: Text(tr([
              'dialogs',
              'new_modpack',
              'actions',
              'create',
            ])),
            onPressed: () =>
                context.read<ProfilesBloc>().add(SubmitNewModpackDialog(
                      widget.profile,
                      state.newModpack!,
                    )),
          ),
          Button(
            child: Text(tr([
              'dialogs',
              'new_modpack',
              'actions',
              'cancel',
            ])),
            onPressed: () =>
                context.read<ProfilesBloc>().add(CloseNewModpackDialog()),
          ),
        ],
      );

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }
}
