import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/profiles/state.dart';

class SettingsRepository {
  late SharedPreferences preferences;

  Future init() => SharedPreferences.getInstance().then((preferences) {
        this.preferences = preferences;
      });

  List<String> get profiles =>
      preferences.getStringList(_Settings.profiles) ?? <String>[];

  set profiles(List<String>? profiles) {
    preferences.setStringList(_Settings.profiles, profiles ?? <String>[]);
  }
}

class _Settings {
  static const String profiles = 'profiles';
}
