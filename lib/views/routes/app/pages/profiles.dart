import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hk_launcher/bloc/profiles/events.dart';
import 'package:hk_launcher/views/routes/app/dialogs/new_profile.dart';

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
            if (state.newProfile != null) {
              showDialog(
                context: context,
                useRootNavigator: false,
                builder: (_) => BlocProvider.value(
                  value: context.read<ProfilesBloc>(),
                  child: const NewProfileDialog(),
                ),
              );
            } else {
              Navigator.of(context).pop();
            }
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
                  message: 'Launch current profile',
                  child: TextButton(
                    child: Row(
                      children: const <Widget>[
                        Icon(FluentIcons.play),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text('Launch'),
                        )
                      ],
                    ),
                    onPressed: state.currentProfile == null ? null : () {},
                  ),
                ),
                tabs: state.profiles
                    .map<Tab>((Profile profile) =>
                        _tab(profile, state.currentProfile == profile.name))
                    .toList(),
                bodies: state.profiles
                    .map<Widget>((Profile profile) => _tabBody(
                        context, profile, state.currentProfile == profile.name))
                    .toList(),
              ),
            ),
          ),
        ),
      );

  Tab _tab(Profile profile, bool isCurrent) => Tab(
        icon: isCurrent
            ? const Icon(
                FluentIcons.favorite_star,
                size: 14,
              )
            : null,
        text: Text(profile.name ?? 'CORRUPT'),
      );

  Widget _tabBody(BuildContext context, Profile profile, bool isCurrent) =>
      SizedBox.expand(
        child: Container(
            padding: const EdgeInsets.all(8),
            color: FluentTheme.of(context).scaffoldBackgroundColor,
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.name ?? 'CORRUPT',
                          style: FluentTheme.of(context).typography.subtitle,
                        ),
                      ),
                      isCurrent
                          ? const Text('This is your current profile')
                          : FilledButton(
                              child: const Text('Make current'),
                              onPressed: () => context
                                  .read<ProfilesBloc>()
                                  .add(MakeProfileCurrent(profile)))
                    ],
                  ),
                  InfoLabel(
                      label: 'Modpacks',
                      child: Card(
                          child: Column(
                              children: profile.modpacks
                                  .map<ListTile>((modpack) =>
                                      ListTile(title: Text(modpack.name)))
                                  .toList()))),
                  InfoLabel(
                    label: 'Manage',
                    child: Expander(
                        header: const Text('Delete this profile?'),
                        content: FilledButton(
                            child: const Text('Yes please'),
                            onPressed: () => context
                                .read<ProfilesBloc>()
                                .add(DeleteProfile(profile)))),
                  )
                ]))),
      );
}
