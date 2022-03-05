import 'dart:convert';

class ProfilesState {
  final int tabIndex;
  final List<Profile> profiles;
  final Profile? newProfile;
  final bool isNewProfileInitializing;
  final String? currentProfile;

  final List<int> hkVersions = const <int>[14, 15];

  const ProfilesState(this.tabIndex, this.profiles,
      {this.newProfile,
      this.isNewProfileInitializing = false,
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
          currentProfile: currentProfile == null
              ? this.currentProfile
              : currentProfile.call());
}

class Profile {
  final String? name;
  final String? hkPath;
  final bool shouldOverwritePath;

  final String? nameError;
  final String? pathError;

  final String? profileError;

  final int hkVersion;

  final List<Modpack> modpacks;

  const Profile(
      {this.name,
      this.hkPath,
      this.shouldOverwritePath = false,
      this.nameError,
      this.pathError,
      this.profileError,
      this.hkVersion = 14,
      this.modpacks = const []});

  Profile copyWith(
          {String? Function()? name,
          String? Function()? hkPath,
          bool Function()? shouldOverwritePath,
          String? Function()? nameError,
          String? Function()? pathError,
          String? Function()? profileError,
          int Function()? hkVersion,
          List<Modpack> Function()? modpacks}) =>
      Profile(
          name: name == null ? this.name : name.call(),
          hkPath: hkPath == null ? this.hkPath : hkPath.call(),
          shouldOverwritePath:
              shouldOverwritePath == null ? false : shouldOverwritePath.call(),
          nameError: nameError == null ? this.nameError : nameError.call(),
          pathError: pathError == null ? this.pathError : pathError.call(),
          profileError:
              profileError == null ? this.profileError : profileError.call(),
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
  final String name;

  Modpack(this.name);
}
