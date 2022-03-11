import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'error_dialog.dart';

import '../../../../bloc/profiles/bloc.dart';
import '../../../../bloc/profiles/events.dart';
import '../../../../bloc/profiles/state.dart';
import '../../../reusable/responsive_progress_ring.dart';

//Shown when creating a new profile
class NewProfileDialog extends StatefulWidget {
  const NewProfileDialog({Key? key}) : super(key: key);

  @override
  State<NewProfileDialog> createState() => _NewProfileDialogState();
}

//Same story as with NewModpackDialog. Have to make this stateful
class _NewProfileDialogState extends State<NewProfileDialog> {
  final TextEditingController pathController = TextEditingController();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProfilesBloc, ProfilesState>(
        builder: (context, state) {
          if (state.newProfile?.shouldOverwritePath ?? false) {
            _overwriteControllerText(pathController, state.newProfile?.hkPath);
          }
          //Depending on current creation progress, show an input form, a progress indicator or an error
          return state.isNewProfileInitializing
              ? _newProfileProgress()
              : state.newProfile?.profileError != null
                  ? _newProfileError(context, state)
                  : _newProfileInput(context, state);
        },
      );

  Widget _newProfileProgress() => const ResponsiveProgressRing();

  Widget _newProfileError(BuildContext context, ProfilesState state) =>
      ErrorDialog(
        'Error occured when creating this profile',
        state.newProfile!.profileError!,
        () => context.read<ProfilesBloc>().add(CloseNewTabDialog()),
      );

  Widget _newProfileInput(BuildContext context, ProfilesState state) =>
      ContentDialog(
        title: const Text('New profile'),
        backgroundDismiss: false,
        content: Column(
          children: <Widget>[
            TextFormBox(
              autovalidateMode: AutovalidateMode.always,
              onChanged: (text) =>
                  context.read<ProfilesBloc>().add(ChangeNewProfileName(text)),
              onFieldSubmitted: (_) =>
                  context.read<ProfilesBloc>().add(SubmitNewTabDialog()),
              validator: (_) => state.newProfile?.nameError,
              placeholder: 'Profile name',
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextFormBox(
                      controller: pathController,
                      autovalidateMode: AutovalidateMode.always,
                      onChanged: (text) => context
                          .read<ProfilesBloc>()
                          .add(ChangeNewProfilePath(text)),
                      onFieldSubmitted: (_) => context
                          .read<ProfilesBloc>()
                          .add(SubmitNewTabDialog()),
                      validator: (_) => state.newProfile?.pathError,
                      placeholder: 'Hollow Knight installation path'),
                ),
                FilledButton(
                  child: const Text('Browse'),
                  onPressed: () =>
                      context.read<ProfilesBloc>().add(PickHKFolder()),
                ),
              ],
            ),
            DropDownButton(
              title: Text('Hollow Knight Version: ' +
                  _hkVersionToString(
                      state.newProfile?.hkVersion ?? state.hkVersions.first)),
              items: state.hkVersions
                  .map<DropDownButtonItem>(
                    (version) => DropDownButtonItem(
                      onTap: () => context
                          .read<ProfilesBloc>()
                          .add(ChangeNewProfileVersion(version)),
                      title: Text(_hkVersionToString(version)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text('Initialize'),
            onPressed: () =>
                context.read<ProfilesBloc>().add(SubmitNewTabDialog()),
          ),
          Button(
            child: const Text('Cancel'),
            onPressed: () =>
                context.read<ProfilesBloc>().add(CloseNewTabDialog()),
          )
        ],
      );

  void _overwriteControllerText(TextEditingController controller,
      [String? newText]) {
    controller
      ..text = newText ?? ''
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
  }

  String _hkVersionToString(int version) {
    final String versionText = version.toString();

    return versionText[0] + '.' + versionText.substring(1);
  }

  @override
  void dispose() {
    pathController.dispose();

    super.dispose();
  }
}
