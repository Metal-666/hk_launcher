import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hk_launcher/bloc/profiles/events.dart';
import 'package:hk_launcher/views/routes/app/dialogs/new_profile.dart';

import '../../../../bloc/profiles/bloc.dart';
import '../../../../bloc/profiles/state.dart';
import '../../../../data/settings/settings_repository.dart';
import '../../../reusable/icon_text_button.dart';
import '../dialogs/error_dialog.dart';

class ProfilesPage extends StatelessWidget {
  const ProfilesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => ProfilesBloc(context.read<SettingsRepository>()),
        child: MultiBlocListener(
          listeners: <BlocListener>[
            BlocListener<ProfilesBloc, ProfilesState>(
                listenWhen: (oldState, newState) =>
                    (oldState.modpackLoadError == null) ^
                    (newState.modpackLoadError == null),
                listener: (context, state) {
                  if (state.modpackLoadError != null) {
                    showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (_) => ErrorDialog('Error loading modpack',
                          state.modpackLoadError!, () {}),
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                }),
            BlocListener<ProfilesBloc, ProfilesState>(
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
            )
          ],
          child: BlocBuilder<ProfilesBloc, ProfilesState>(
            buildWhen: (oldState, newState) =>
                oldState.tabIndex != newState.tabIndex ||
                oldState.profiles.length != newState.profiles.length ||
                oldState.currentProfile != newState.currentProfile,
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
                  onNewPressed: () =>
                      context.read<ProfilesBloc>().add(AddTab()),
                  closeButtonVisibility: CloseButtonVisibilityMode.never,
                  footer: Tooltip(
                    message: 'Launch current profile',
                    child: IconTextButton(FluentIcons.play, 'Launch',
                        state.currentProfile == null ? null : () {},
                        buttonType: ButtonType.text),
                  ),
                  tabs: state.profiles
                      .map<Tab>((Profile profile) =>
                          _tab(profile, state.currentProfile == profile.name))
                      .toList(),
                  bodies: state.profiles
                      .map<Widget>((Profile profile) => _tabBody(context,
                          profile, state.currentProfile == profile.name))
                      .toList(),
                ),
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
                                  .map<Widget>(
                                    (modpack) => Row(children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: IconButton(
                                          icon: Icon(profile.selectedModpack ==
                                                  modpack.name
                                              ? FluentIcons.favorite_star_fill
                                              : FluentIcons.favorite_star),
                                          onPressed: () => context
                                              .read<ProfilesBloc>()
                                              .add(SelectModpack(
                                                  profile, modpack)),
                                        ),
                                      ),
                                      Expanded(
                                        child: Expander(
                                            header: Text(modpack.name),
                                            content: Row(
                                              children: <Widget>[
                                                IconTextButton(
                                                    FluentIcons.dependency_add,
                                                    'Duplicate',
                                                    () {}),
                                                IconTextButton(
                                                    FluentIcons.delete,
                                                    'Delete',
                                                    () {}),
                                                IconTextButton(
                                                    FluentIcons.folder,
                                                    'Show',
                                                    () => context
                                                        .read<ProfilesBloc>()
                                                        .add(
                                                            ShowModpackInExplorer(
                                                                profile,
                                                                modpack)))
                                              ],
                                            )),
                                      )
                                    ]),
                                  )
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
