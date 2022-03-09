import 'package:fluent_ui/fluent_ui.dart';

abstract class SettingsEvent {}

class ThemeModeChanged extends SettingsEvent {
  final ThemeMode themeMode;

  ThemeModeChanged(this.themeMode);
}

class RestoreHK extends SettingsEvent {}
