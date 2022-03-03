import 'dart:convert';

class ProfilesState {
  final int tabIndex;
  final List<Profile> profiles;
  final Profile? newProfile;
  final bool isNewProfileInitializing;
  final String? newProfileError;
  final String? currentProfile;

  final List<int> hkVersions = const <int>[14, 15];

  const ProfilesState(this.tabIndex, this.profiles,
      {this.newProfile,
      this.isNewProfileInitializing = false,
      this.newProfileError,
      this.currentProfile});

  ProfilesState copyWith(
          {int Function()? tabIndex,
          List<Profile> Function()? profiles,
          Profile? Function()? newProfile,
          bool Function()? isNewProfileInitializing,
          String? Function()? newProfileError,
          String? Function()? currentProfile}) =>
      ProfilesState(tabIndex == null ? this.tabIndex : tabIndex.call(),
          profiles == null ? this.profiles : profiles.call(),
          newProfile: newProfile == null ? this.newProfile : newProfile.call(),
          isNewProfileInitializing: isNewProfileInitializing == null
              ? this.isNewProfileInitializing
              : isNewProfileInitializing.call(),
          newProfileError: newProfileError == null
              ? this.newProfileError
              : newProfileError.call(),
          currentProfile: currentProfile == null
              ? this.currentProfile
              : currentProfile.call());
}

class Profile {
  final String? name;
  final String? hkPath;

  final String? nameError;
  final String? pathError;

  final int hkVersion;

  final List<Modpack> modpacks;

  const Profile(
      {this.name,
      this.hkPath,
      this.nameError,
      this.pathError,
      this.hkVersion = 14,
      this.modpacks = const []});

  Profile copyWith(
          {String? Function()? name,
          String? Function()? hkPath,
          String? Function()? nameError,
          String? Function()? pathError,
          int Function()? hkVersion,
          List<Modpack> Function()? modpacks}) =>
      Profile(
          name: name == null ? this.name : name.call(),
          hkPath: hkPath == null ? this.hkPath : hkPath.call(),
          nameError: nameError == null ? this.nameError : nameError.call(),
          pathError: pathError == null ? this.pathError : pathError.call(),
          hkVersion: hkVersion == null ? this.hkVersion : hkVersion.call(),
          modpacks: modpacks == null ? this.modpacks : modpacks.call());

  Map<String, dynamic> toMap() =>
      {'name': name, 'hk_path': hkPath, 'hk_version': hkVersion};

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
      name: map['name'], hkPath: map['hk_path'], hkVersion: map['hk_version']);

  String toJson() => json.encode(toMap());

  factory Profile.fromJson(String source) =>
      Profile.fromMap(json.decode(source));
}

class Modpack {
  String? name;
}
