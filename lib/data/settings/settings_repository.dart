import 'package:shared_preferences/shared_preferences.dart';

// Acts like a wrapper to SharedPreferences. Used by almost all blocs to store and retrieve data
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

  String? get themeMode => preferences.getString(_Settings.themeMode);

  set themeMode(String? themeMode) {
    if (themeMode == null) {
      preferences.remove(_Settings.themeMode);
    } else {
      preferences.setString(_Settings.themeMode, themeMode);
    }
  }

  String? get currentProfile => preferences.getString(_Settings.currentProfile);

  set currentProfile(String? currentProfile) {
    if (currentProfile == null) {
      preferences.remove(_Settings.currentProfile);
    } else {
      preferences.setString(_Settings.currentProfile, currentProfile);
    }
  }

  bool get seenDisclaimer =>
      preferences.getBool(_Settings.seenDisclaimer) ?? false;

  set seenDisclaimer(bool seenDisclaimer) {
    preferences.setBool(_Settings.seenDisclaimer, seenDisclaimer);
  }
}

class _Settings {
  static const String profiles = 'profiles',
      themeMode = 'themeMode',
      currentProfile = 'currentProfile',
      seenDisclaimer = 'seenDisclaimer';
}
