import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/profiles/bloc.dart';
import '../../../../bloc/profiles/events.dart';
import '../../../../bloc/profiles/state.dart';
import '../../../../data/settings/settings_repository.dart';
import '../../../../util/translations.dart';
import '../../../reusable/icon_text_button.dart';
import '../../../reusable/nested_expander.dart';
import '../../../reusable/responsive_progress_ring.dart';
import '../dialogs/error_dialog.dart';
import '../dialogs/new_modpack.dart';
import '../dialogs/new_profile.dart';

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
                    builder: (_) => ErrorDialog(
                      'Error loading modpack',
                      state.modpackLoadError!,
                      () => context
                          .read<ProfilesBloc>()
                          .add(CloseModpackErrorDialog()),
                    ),
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
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
            ),
            BlocListener<ProfilesBloc, ProfilesState>(
              listenWhen: (oldState, newState) =>
                  (oldState.isDoingStuff) ^ (newState.isDoingStuff),
              listener: (context, state) {
                if (state.isDoingStuff) {
                  showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (_) => const ResponsiveProgressRing(),
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
          child: BlocBuilder<ProfilesBloc, ProfilesState>(
            builder: (context, state) => ScaffoldPage(
              padding: EdgeInsets.zero,
              header: Mica(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: PageHeader(
                      title: Text(tr([
                    'navigation_panel',
                    'profiles',
                  ]))),
                ),
              ),
              content: Mica(
                backgroundColor: state.profiles.isEmpty
                    ? FluentTheme.of(context).acrylicBackgroundColor
                    : null,
                child: _tabView(context, state),
              ),
            ),
          ),
        ),
      );

  Widget _tabView(BuildContext context, ProfilesState state) => TabView(
        wheelScroll: true,
        currentIndex: state.tabIndex,
        onChanged: (index) =>
            context.read<ProfilesBloc>().add(ChangeTab(index)),
        onNewPressed: () => context.read<ProfilesBloc>().add(AddTab()),
        closeButtonVisibility: CloseButtonVisibilityMode.never,
        footer: Tooltip(
          message: 'Launch current profile',
          child: IconTextButton(
            FluentIcons.play,
            tr([
              'pages',
              'profiles',
              'tab_strip',
              'launch',
            ]),
            state.currentProfile == null
                ? null
                : () => context.read<ProfilesBloc>().add(LaunchHK()),
            buttonType: ButtonType.text,
          ),
        ),
        tabs: state.profiles
            .map<Tab>((profile) => _tab(
                  profile,
                  state.currentProfile == profile.name,
                ))
            .toList(),
        bodies: state.profiles
            .map<Widget>((profile) => _tabBody(
                  context,
                  profile,
                  state.currentProfile == profile.name,
                ))
            .toList(),
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
      BlocListener<ProfilesBloc, ProfilesState>(
        listenWhen: (oldState, newState) =>
            (oldState.newModpack == null) ^ (newState.newModpack == null),
        listener: (context, state) {
          if (state.newModpack != null) {
            showDialog(
              context: context,
              useRootNavigator: false,
              builder: (_) => BlocProvider.value(
                value: context.read<ProfilesBloc>(),
                child: NewModpackDialog(profile),
              ),
            );
          } else {
            Navigator.of(context).pop();
          }
        },
        child: SizedBox.expand(
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
                          ? Text(tr([
                              'pages',
                              'profiles',
                              'content',
                              'current_button',
                              'selected',
                            ]))
                          : FilledButton(
                              child: Text(tr([
                                'pages',
                                'profiles',
                                'content',
                                'current_button',
                                'unselected',
                              ])),
                              onPressed: () => context
                                  .read<ProfilesBloc>()
                                  .add(MakeProfileCurrent(profile)),
                            ),
                    ],
                  ),
                  InfoLabel(
                    label: tr([
                      'pages',
                      'profiles',
                      'content',
                      'modpacks',
                      'header',
                    ]),
                    child: Card(
                      child: Column(
                        children: profile.modpacks
                            .map<Widget>(
                              (modpack) => Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: IconButton(
                                      icon: Icon(profile.selectedModpack ==
                                              modpack.name
                                          ? FluentIcons.favorite_star_fill
                                          : FluentIcons.favorite_star),
                                      onPressed: () => context
                                          .read<ProfilesBloc>()
                                          .add(SelectModpack(profile, modpack)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Expander(
                                      header: Text(modpack.name ?? 'ERROR'),
                                      content: Row(
                                        children: <Widget>[
                                          IconTextButton(
                                            FluentIcons.dependency_add,
                                            'Duplicate',
                                            () => context
                                                .read<ProfilesBloc>()
                                                .add(DuplicateModpack(modpack)),
                                          ),
                                          IconTextButton(
                                            FluentIcons.delete,
                                            tr([
                                              'pages',
                                              'profiles',
                                              'content',
                                              'modpacks',
                                              'item',
                                              'expander',
                                              'delete',
                                              modpack.deletionSureness
                                                  .toString(),
                                            ]),
                                            modpack.name == 'Vanilla'
                                                ? null
                                                : () => context
                                                    .read<ProfilesBloc>()
                                                    .add(DeleteModpack(
                                                        profile, modpack)),
                                          ),
                                          IconTextButton(
                                            FluentIcons.folder,
                                            tr([
                                              'pages',
                                              'profiles',
                                              'content',
                                              'modpacks',
                                              'item',
                                              'expander',
                                              'show',
                                            ]),
                                            () => context
                                                .read<ProfilesBloc>()
                                                .add(ShowModpackInExplorer(
                                                    profile, modpack)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  InfoLabel(
                    label: tr([
                      'pages',
                      'profiles',
                      'content',
                      'manage',
                      'header',
                    ]),
                    child: NestedExpander(
                      headerOuter: Text(tr([
                        'pages',
                        'profiles',
                        'content',
                        'manage',
                        'expander',
                        'header',
                      ])),
                      headerInner: Text(tr([
                        'pages',
                        'profiles',
                        'content',
                        'manage',
                        'expander',
                        'expander',
                        'header',
                      ])),
                      contentOuter: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                                text: tr([
                              'pages',
                              'profiles',
                              'content',
                              'manage',
                              'expander',
                              'content',
                              'part-1',
                            ])),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Mica(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text.rich(
                                    TextSpan(
                                      children: <InlineSpan>[
                                        WidgetSpan(
                                            child: Icon(FluentIcons.folder)),
                                        TextSpan(
                                            text: tr([
                                          'pages',
                                          'profiles',
                                          'content',
                                          'manage',
                                          'expander',
                                          'content',
                                          'button-label',
                                        ]))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                                text: tr([
                              'pages',
                              'profiles',
                              'content',
                              'manage',
                              'expander',
                              'content',
                              'part-2',
                            ])),
                          ],
                        ),
                      ),
                      contentInner: FilledButton(
                        child: Text(tr([
                          'pages',
                          'profiles',
                          'content',
                          'manage',
                          'expander',
                          'expander',
                          'button',
                        ])),
                        onPressed: () => context
                            .read<ProfilesBloc>()
                            .add(DeleteProfile(profile)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
