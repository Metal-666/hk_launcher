import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hk_launcher/data/settings/settings_repository.dart';

import '../../bloc/settings/bloc.dart';
import '../../bloc/settings/events.dart';
import '../../bloc/settings/state.dart';
import '../../util/converters.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const SizedBox spacer = SizedBox(height: 10.0);

    return BlocProvider<SettingsBloc>(
      create: (context) => SettingsBloc(context.read<SettingsRepository>()),
      child: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.needsRestart) {
            GoRouter.of(context).go('/loading');
          }
        },
        child: ScaffoldPage.scrollable(
          header: const PageHeader(title: Text('Settings')),
          children: <Widget>[
            Text('Theme mode',
                style: FluentTheme.of(context).typography.subtitle),
            spacer,
            ...List.generate(ThemeMode.values.length, (index) {
              final mode = ThemeMode.values[index];

              return BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RadioButton(
                      checked: state.themeMode == mode,
                      onChanged: (changed) {
                        if (changed) {
                          context
                              .read<SettingsBloc>()
                              .add(ThemeModeChanged(mode));
                        }
                      },
                      content:
                          Text(themeModeConverter.inverse[mode] ?? 'ERROR'),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
