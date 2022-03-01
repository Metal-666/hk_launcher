import 'dart:convert';

class ProfilesState {
  int tabIndex;
  List<Profile> profiles;
  Profile? newProfile;
  String? currentProfile;

  ProfilesState(this.tabIndex, this.profiles,
      {this.newProfile, this.currentProfile});

  ProfilesState copyWith(
          {int Function()? tabIndex,
          List<Profile> Function()? profiles,
          Profile? Function()? newProfile,
          String? Function()? currentProfile}) =>
      ProfilesState(tabIndex == null ? this.tabIndex : tabIndex.call(),
          profiles == null ? this.profiles : profiles.call(),
          newProfile: newProfile == null ? this.newProfile : newProfile.call(),
          currentProfile: currentProfile == null
              ? this.currentProfile
              : currentProfile.call());
}

class Profile {
  String? name;
  String? hkPath;

  String? nameError;
  String? pathError;

  List<Modpack> modpacks;

  Profile(
      {this.name,
      this.hkPath,
      this.nameError,
      this.pathError,
      this.modpacks = const []});

  Profile copyWith(
          {String? Function()? name,
          String? Function()? hkPath,
          String? Function()? nameError,
          String? Function()? pathError,
          List<Modpack> Function()? modpacks}) =>
      Profile(
          name: name == null ? this.name : name.call(),
          hkPath: hkPath == null ? this.hkPath : hkPath.call(),
          nameError: nameError == null ? this.nameError : nameError.call(),
          pathError: pathError == null ? this.pathError : pathError.call(),
          modpacks: modpacks == null ? this.modpacks : modpacks.call());

  Map<String, dynamic> toMap() => {'name': name, 'hk_path': hkPath};

  factory Profile.fromMap(Map<String, dynamic> map) =>
      Profile(name: map['name'], hkPath: map['hk_path']);

  String toJson() => json.encode(toMap());

  factory Profile.fromJson(String source) =>
      Profile.fromMap(json.decode(source));
}

class Modpack {}
