import 'package:fluent_ui/fluent_ui.dart';

abstract class SettingsEvent {}

class ThemeModeChanged extends SettingsEvent {
  ThemeMode themeMode;

  ThemeModeChanged(this.themeMode);
}
