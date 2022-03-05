import 'package:fluent_ui/fluent_ui.dart';
import 'package:quiver/collection.dart';

class SettingsState {
  final bool needsRestart;

  final ThemeMode themeMode;

  SettingsState(this.needsRestart, this.themeMode);

  SettingsState copyWith(
          {bool Function()? needsRestart, ThemeMode Function()? themeMode}) =>
      SettingsState(
          needsRestart == null ? this.needsRestart : needsRestart.call(),
          themeMode == null ? this.themeMode : themeMode.call());
}
