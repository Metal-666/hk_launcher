import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/profiles/bloc.dart';
import '../../../../bloc/profiles/events.dart';
import '../../../../bloc/profiles/state.dart';
import '../../../reusable/responsive_progress_ring.dart';

class NewProfileDialog extends StatelessWidget {
  const NewProfileDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProfilesBloc, ProfilesState>(
        builder: (context, state) => state.isNewProfileInitializing
            ? const ResponsiveProgressRing()
            : state.newProfile?.profileError != null
                ? ContentDialog(
                    title:
                        const Text('Error occured when creating this profile'),
                    backgroundDismiss: false,
                    content: Text(
                      state.newProfile!.profileError!,
                      style: FluentTheme.of(context).typography.bodyLarge,
                    ),
                    actions: <Widget>[
                        Button(
                            child: const Text('Close'),
                            onPressed: () => context
                                .read<ProfilesBloc>()
                                .add(CloseNewTabDialog()))
                      ])
                : ContentDialog(
                    title: const Text('New profile'),
                    backgroundDismiss: false,
                    content: Column(
                      children: <Widget>[
                        TextFormBox(
                          initialValue: state.newProfile?.name,
                          autovalidateMode: AutovalidateMode.always,
                          onChanged: (text) => context
                              .read<ProfilesBloc>()
                              .add(ChangeNewProfileName(text)),
                          validator: (_) => state.newProfile?.nameError,
                          placeholder: 'Profile name',
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: TextFormBox(
                                  initialValue: state.newProfile?.hkPath,
                                  autovalidateMode: AutovalidateMode.always,
                                  onChanged: (text) => context
                                      .read<ProfilesBloc>()
                                      .add(ChangeNewProfilePath(text)),
                                  validator: (_) => state.newProfile?.pathError,
                                  placeholder:
                                      'Hollow Knight installation path'),
                            ),
                            FilledButton(
                                child: const Text('Browse'),
                                onPressed: () => context
                                    .read<ProfilesBloc>()
                                    .add(PickHKFolder()))
                          ],
                        ),
                        DropDownButton(
                            title: Text('Hollow Knight Version: ' +
                                _hkVersionToString(
                                    state.newProfile?.hkVersion ??
                                        state.hkVersions.first)),
                            items: state.hkVersions
                                .map<DropDownButtonItem>((version) =>
                                    DropDownButtonItem(
                                        onTap: () => context
                                            .read<ProfilesBloc>()
                                            .add(ChangeNewProfileVersion(
                                                version)),
                                        title:
                                            Text(_hkVersionToString(version))))
                                .toList())
                      ],
                    ),
                    actions: [
                      Button(
                          child: const Text('Initialize'),
                          onPressed: () {
                            context
                                .read<ProfilesBloc>()
                                .add(SubmitNewTabDialog());
                          }),
                      Button(
                          child: const Text('Cancel'),
                          onPressed: () => context
                              .read<ProfilesBloc>()
                              .add(CloseNewTabDialog()))
                    ],
                  ),
      );

  String _hkVersionToString(int version) {
    final String versionText = version.toString();
    return versionText[0] + '.' + versionText.substring(1);
  }
}
