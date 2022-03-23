import 'package:fluent_ui/fluent_ui.dart';

abstract class SettingsEvent {}

class ThemeModeChanged extends SettingsEvent {
  final ThemeMode themeMode;

  ThemeModeChanged(this.themeMode);
}

class LocaleChanged extends SettingsEvent {
  final String locale;

  LocaleChanged(this.locale);
}

class RestoreHK extends SettingsEvent {}
