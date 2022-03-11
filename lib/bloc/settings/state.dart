import 'package:fluent_ui/fluent_ui.dart';

class SettingsState {
  final bool needsRestart;

  final ThemeMode themeMode;

  final bool restoringHK;

  const SettingsState(
      {this.needsRestart = false,
      required this.themeMode,
      this.restoringHK = false});

  SettingsState copyWith(
          {bool Function()? needsRestart,
          ThemeMode Function()? themeMode,
          bool Function()? restoringHK}) =>
      SettingsState(
        needsRestart:
            needsRestart == null ? this.needsRestart : needsRestart.call(),
        themeMode: themeMode == null ? this.themeMode : themeMode.call(),
        restoringHK:
            restoringHK == null ? this.restoringHK : restoringHK.call(),
      );
}
