import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hk_launcher/bloc/profiles/events.dart';

import '../../../../bloc/profiles/bloc.dart';
import '../../../../bloc/profiles/state.dart';
import '../../../../data/settings/settings_repository.dart';

class ProfilesPage extends StatelessWidget {
  const ProfilesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => ProfilesBloc(context.read<SettingsRepository>()),
        child: BlocConsumer<ProfilesBloc, ProfilesState>(
          listenWhen: (oldState, newState) =>
              (oldState.newProfile == null) ^ (newState.newProfile == null),
          listener: (context, state) {
            /*if (state.newProfile != null) {
              final TextEditingController nameController =
                      TextEditingController(),
                  pathController = TextEditingController();

              showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<ProfilesBloc>(),
                  child: ContentDialog(
                    title: const Text('New profile'),
                    backgroundDismiss: false,
                    content: BlocConsumer<ProfilesBloc, ProfilesState>(
                      listener: (context, state) {
                        pathController.text = state.newProfile?.hkPath ?? '';
                      },
                      builder: (context, state) => Column(
                        children: <Widget>[
                          TextFormBox(
                            controller: nameController,
                            autovalidateMode: AutovalidateMode.always,
                            validator: (_) => state.newProfile?.nameError,
                            placeholder: 'Profile name',
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: TextFormBox(
                                    controller: pathController,
                                    autovalidateMode: AutovalidateMode.always,
                                    validator: (_) =>
                                        state.newProfile?.pathError,
                                    placeholder:
                                        'Hollow Knight installation path'),
                              ),
                              FilledButton(
                                  child: const Text('Browse'),
                                  onPressed: () => context
                                      .read<ProfilesBloc>()
                                      .add(PickHKFolder()))
                            ],
                          )
                        ],
                      ),
                    ),
                    actions: [
                      Button(
                          child: const Text('Done'),
                          onPressed: () {
                            context.read<ProfilesBloc>().add(SubmitNewTabDialog(
                                nameController.text, pathController.text));
                          }),
                      Button(
                          child: const Text('Cancel'),
                          onPressed: () => context
                              .read<ProfilesBloc>()
                              .add(CloseNewTabDialog()))
                    ],
                  ),
                ),
              );
            } else {
              Navigator.of(context, rootNavigator: true).pop();
            }*/
          },
          builder: (context, state) => ScaffoldPage(
            padding: EdgeInsets.zero,
            header: const Mica(
                child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: PageHeader(title: Text('Profiles')),
            )),
            content: Mica(
              child: TabView(
                wheelScroll: true,
                currentIndex: state.tabIndex,
                onChanged: (index) =>
                    context.read<ProfilesBloc>().add(ChangeTab(index)),
                onNewPressed: () => context.read<ProfilesBloc>().add(AddTab()),
                closeButtonVisibility: CloseButtonVisibilityMode.never,
                footer: Tooltip(
                  message: 'Synchronize filesystem with current profile',
                  child: TextButton(
                    child: Row(
                      children: const <Widget>[
                        Icon(FluentIcons.sync),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text('Sync'),
                        )
                      ],
                    ),
                    onPressed: state.currentProfile == null ? null : () {},
                  ),
                ),
                tabs: state.profiles
                    .map<Tab>((Profile profile) => _tab(state, profile))
                    .toList(),
                bodies: state.profiles
                    .map<Widget>(
                        (Profile profile) => _tabBody(context, profile))
                    .toList(),
              ),
            ),
          ),
        ),
      );
  Tab _tab(ProfilesState state, Profile profile) => Tab(
        icon: profile.name == state.currentProfile
            ? const Icon(FluentIcons.accept)
            : null,
        text: Text(profile.name ?? 'CORRUPT'),
      );

  Widget _tabBody(BuildContext context, Profile profile) => SizedBox.expand(
        child: Container(
            color: FluentTheme.of(context).scaffoldBackgroundColor,
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                  InfoLabel(label: profile.name ?? 'CORRUPT'),
                  ListView(),
                  Expander(
                      header: const Text('Delete this profile?'),
                      content: FilledButton(
                          child: const Text('Yes please'),
                          onPressed: () => context
                              .read<ProfilesBloc>()
                              .add(DeleteProfile(profile))))
                ]))),
      );
}
