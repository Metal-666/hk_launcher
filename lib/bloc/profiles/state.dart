import 'dart:convert';

class ProfilesState {
  int tabIndex;
  List<Profile> profiles;
  Profile? newProfile;

  ProfilesState(this.tabIndex, this.profiles, {this.newProfile});

  ProfilesState copyWith(
          {int Function()? tabIndex,
          List<Profile> Function()? profiles,
          Profile? Function()? newProfile}) =>
      ProfilesState(tabIndex == null ? this.tabIndex : tabIndex.call(),
          profiles == null ? this.profiles : profiles.call(),
          newProfile: newProfile == null ? this.newProfile : newProfile.call());
}

class Profile {
  String? name;
  String? hkPath;

  String? nameError;
  String? pathError;

  Profile({this.name, this.hkPath, this.nameError, this.pathError});

  Profile copyWith(
          {String? Function()? name,
          String? Function()? hkPath,
          String? Function()? nameError,
          String? Function()? pathError}) =>
      Profile(
          name: name == null ? this.name : name.call(),
          hkPath: hkPath == null ? this.hkPath : hkPath.call(),
          nameError: nameError == null ? this.nameError : nameError.call(),
          pathError: pathError == null ? this.pathError : pathError.call());

  Map<String, dynamic> toMap() => {
        'name': name,
        'hk_path': hkPath,
      };

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        name: map['name'],
        hkPath: map['hk_path'],
      );

  String toJson() => json.encode(toMap());

  factory Profile.fromJson(String source) =>
      Profile.fromMap(json.decode(source));
}
