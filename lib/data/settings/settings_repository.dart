import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  late SharedPreferences preferences;

  Future init() => SharedPreferences.getInstance().then((preferences) {
        this.preferences = preferences;
        return;
      });

  String? get hkPath => preferences.getString(_Settings.hkPath);

  set hkPath(String? path) {
    if (path == null) {
      preferences.remove(_Settings.hkPath);
    } else {
      preferences.setString(_Settings.hkPath, path);
    }
  }
}

class _Settings {
  static const String hkPath = 'hk_path';
}
