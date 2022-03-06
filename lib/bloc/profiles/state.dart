import 'dart:convert';

class ProfilesState {
  final int tabIndex;
  final List<Profile> profiles;
  final Profile? newProfile;
  final bool isNewProfileInitializing;
  final String? currentProfile;

  final String? modpackLoadError;

  final Modpack? newModpack;
  final bool isNewModpackInitializing;

  final List<int> hkVersions = const <int>[14, 15];

  const ProfilesState(this.tabIndex, this.profiles,
      {this.newProfile,
      this.isNewProfileInitializing = false,
      this.currentProfile,
      this.modpackLoadError,
      this.newModpack,
      this.isNewModpackInitializing = false});

  ProfilesState copyWith(
          {int Function()? tabIndex,
          List<Profile> Function()? profiles,
          Profile? Function()? newProfile,
          bool Function()? isNewProfileInitializing,
          String? Function()? currentProfile,
          String? Function()? modpackLoadError,
          Modpack? Function()? newModpack,
          bool Function()? isNewModpackInitializing}) =>
      ProfilesState(tabIndex == null ? this.tabIndex : tabIndex.call(),
          profiles == null ? this.profiles : profiles.call(),
          newProfile: newProfile == null ? this.newProfile : newProfile.call(),
          isNewProfileInitializing: isNewProfileInitializing == null
              ? this.isNewProfileInitializing
              : isNewProfileInitializing.call(),
          currentProfile: currentProfile == null
              ? this.currentProfile
              : currentProfile.call(),
          modpackLoadError: modpackLoadError == null
              ? this.modpackLoadError
              : modpackLoadError.call(),
          newModpack: newModpack == null ? this.newModpack : newModpack.call(),
          isNewModpackInitializing: isNewModpackInitializing == null
              ? this.isNewModpackInitializing
              : isNewModpackInitializing.call());
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

  final String selectedModpack;

  const Profile(
      {this.name,
      this.hkPath,
      this.shouldOverwritePath = false,
      this.nameError,
      this.pathError,
      this.profileError,
      this.hkVersion = 14,
      this.modpacks = const [],
      this.selectedModpack = 'Vanilla'});

  Profile copyWith(
          {String? Function()? name,
          String? Function()? hkPath,
          bool Function()? shouldOverwritePath,
          String? Function()? nameError,
          String? Function()? pathError,
          String? Function()? profileError,
          int Function()? hkVersion,
          List<Modpack> Function()? modpacks,
          String Function()? selectedModpack}) =>
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
          modpacks: modpacks == null ? this.modpacks : modpacks.call(),
          selectedModpack: selectedModpack == null
              ? this.selectedModpack
              : selectedModpack.call());

  Map<String, dynamic> toMap() => {
        'name': name,
        'hk_path': hkPath,
        'hk_version': hkVersion,
        'selected_modpack': selectedModpack
      };

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
      name: map['name'],
      hkPath: map['hk_path'],
      hkVersion: map['hk_version'],
      selectedModpack: map['selected_modpack'] ?? 'Vanilla');

  String toJson() => json.encode(toMap());

  factory Profile.fromJson(String source) =>
      Profile.fromMap(json.decode(source));
}

class Modpack {
  final String? name;

  final String? nameError;

  final String? basedOn;

  const Modpack({this.name, this.nameError, this.basedOn});

  Modpack copyWith({
    String Function()? name,
    String Function()? nameError,
    String Function()? basedOn,
  }) =>
      Modpack(
          name: name == null ? this.name : name.call(),
          nameError: nameError == null ? this.nameError : nameError.call(),
          basedOn: basedOn == null ? this.basedOn : basedOn.call());
}
