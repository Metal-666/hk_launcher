import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  late SharedPreferences preferences;

  Future init() => SharedPreferences.getInstance().then((preferences) {
        this.preferences = preferences;
        return;
      });

  String? get hkPath {
    String? path = preferences.getString('hk_path');

    if (path != null && Directory(path + 'Hollow Knight_Data').existsSync()) {
      return path;
    } else {
      return null;
    }
  }
}
