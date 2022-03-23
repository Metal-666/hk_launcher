import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hk_launcher/util/translations.dart';
import '../../../../data/settings/settings_repository.dart';
import '../../../reusable/responsive_progress_ring.dart';

import '../../../../bloc/settings/bloc.dart';
import '../../../../bloc/settings/events.dart';
import '../../../../bloc/settings/state.dart';
import '../../../../util/converters.dart';
import '../../../../util/extensions.dart';
import '../../../reusable/nested_expander.dart';

class SettingsPage extends StatelessWidget {
  final SizedBox spacer = const SizedBox(height: 10);

  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider<SettingsBloc>(
        create: (context) => SettingsBloc(context.read<SettingsRepository>()),
        child: MultiBlocListener(
          listeners: [
            BlocListener<SettingsBloc, SettingsState>(
              listener: (context, state) {
                if (state.needsRestart) {
                  GoRouter.of(context).go('/loading');
                }
              },
            ),
            BlocListener<SettingsBloc, SettingsState>(
              listenWhen: (oldState, newState) =>
                  (oldState.restoringHK) ^ (newState.restoringHK),
              listener: (context, state) {
                if (state.restoringHK) {
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
          child: ScaffoldPage.scrollable(
            header:
                PageHeader(title: Text(tr(['navigation_panel', 'settings']))),
            children: <Widget>[
              _themeMode(context),
              _language(context),
              _other(context),
            ],
          ),
        ),
      );

  Widget _themeMode(BuildContext context) =>
      BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) => _setting(
          context,
          tr(['pages', 'settings', 'theme_mode', 'header']),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(
              ThemeMode.values.length,
              (index) {
                final mode = ThemeMode.values[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RadioButton(
                    checked: state.themeMode == mode,
                    onChanged: (changed) {
                      if (changed) {
                        context
                            .read<SettingsBloc>()
                            .add(ThemeModeChanged(mode));
                      }
                    },
                    content: Text(
                        themeModeConverter.inverse[mode]?.toCapitalized() ??
                            'ERROR'),
                  ),
                );
              },
            ),
          ),
        ),
      );

  Widget _language(BuildContext context) =>
      BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) => _setting(
          context,
          tr(['pages', 'settings', 'language']),
          DropDownButton(
              title: Text(locales[currentLocale] ?? 'ERROR'),
              items: locales.keys
                  .map<DropDownButtonItem>((locale) => DropDownButtonItem(
                        title: Text(locales[locale] ?? 'ERROR'),
                        onTap: () => context
                            .read<SettingsBloc>()
                            .add(LocaleChanged(locale)),
                      ))
                  .toList()),
        ),
      );

  Widget _other(BuildContext context) =>
      BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) => _setting(
          context,
          tr(['pages', 'settings', 'other', 'header']),
          NestedExpander(
            headerOuter: Text(tr(['settings', 'other', 'restore'])),
            contentOuter: const Text(
                'This will simply delete all your profiles. As usual, you will need to restore your original save files yourself.'),
            headerInner: const Text('Proceed'),
            contentInner: FilledButton(
              child: const Text('Yeeeeeet'),
              onPressed: () => context.read<SettingsBloc>().add(RestoreHK()),
            ),
          ),
        ),
      );

  // Really wish this was part of a fluent_ui package
  Widget _setting(BuildContext context, String header, Widget content) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(header, style: FluentTheme.of(context).typography.subtitle),
          spacer,
          content,
        ],
      );
}
