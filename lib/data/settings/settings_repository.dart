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

  String? get themeMode => preferences.getString('themeMode');

  set themeMode(String? themeMode) {
    if (themeMode == null) {
      preferences.remove(_Settings.themeMode);
    } else {
      preferences.setString(_Settings.themeMode, themeMode);
    }
  }

  String? get currentProfile => preferences.getString('currentProfile');

  set currentProfile(String? currentProfile) {
    if (currentProfile == null) {
      preferences.remove(_Settings.currentProfile);
    } else {
      preferences.setString(_Settings.currentProfile, currentProfile);
    }
  }
}

class _Settings {
  static const String profiles = 'profiles',
      themeMode = 'themeMode',
      currentProfile = 'currentProfile';
}
