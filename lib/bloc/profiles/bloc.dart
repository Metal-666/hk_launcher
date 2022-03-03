import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';

import '../../data/settings/settings_repository.dart';
import 'events.dart';
import 'state.dart';

class ProfilesBloc extends Bloc<ProfilesEvent, ProfilesState> {
  final SettingsRepository _settingsRepository;

  ProfilesBloc(this._settingsRepository)
      : super(ProfilesState(
            0,
            _settingsRepository.profiles
                .map<Profile>((profile) => Profile.fromJson(profile))
                .toList(),
            currentProfile: _settingsRepository.currentProfile)) {
    on<ChangeTab>(
        (event, emit) => emit(state.copyWith(tabIndex: () => event.index)));
    on<AddTab>((event, emit) => emit(state.copyWith(
        newProfile: () => const Profile(), newProfileError: () => null)));
    on<PickHKFolder>((event, emit) async {
      String? path = await FilePicker.platform.getDirectoryPath();

      if (path != null) {
        emit(state.copyWith(
            newProfile: () => state.newProfile?.copyWith(hkPath: () => path)));
      }
    });
    on<CloseNewTabDialog>(
        (event, emit) => emit(state.copyWith(newProfile: () => null)));
    on<ChangeNewProfileName>((event, emit) => emit(state.copyWith(
        newProfile: () => state.newProfile?.copyWith(name: () => event.name))));
    on<ChangeNewProfilePath>((event, emit) => emit(state.copyWith(
        newProfile: () =>
            state.newProfile?.copyWith(hkPath: () => event.path))));
    on<ChangeNewProfileVersion>((event, emit) => emit(state.copyWith(
        newProfile: () =>
            state.newProfile?.copyWith(hkVersion: () => event.version))));
    on<SubmitNewTabDialog>((event, emit) async {
      String? nameError = _validateProfileName(state.newProfile?.name);
      String? pathError = _validateHKPath(
          state.newProfile?.hkPath, state.newProfile?.hkVersion ?? -1);

      if (nameError == null && pathError == null) {
        emit(state.copyWith(isNewProfileInitializing: () => true));
        try {
          Directory modpacksDir =
              Directory(join(state.newProfile!.hkPath!, 'Modpacks', 'Vanilla'));
          await modpacksDir.create(recursive: true);
        } on FileSystemException catch (exception) {
          emit(state.copyWith(
              isNewProfileInitializing: () => false,
              newProfileError: () =>
                  exception.osError?.message ?? 'Unknown error'));
        }
        //Directory(join(event.path), '')
        /*Profile newProfile = Profile(name: event.name, hkPath: event.path);
        emit(state.copyWith(
            newProfile: () => null,
            profiles: () => List.of(state.profiles)..add(newProfile)));

        _settingsRepository.profiles =
            state.profiles.map<String>((profile) => profile.toJson()).toList();*/
      } else {
        emit(state.copyWith(
            newProfile: () => state.newProfile?.copyWith(
                nameError: () => nameError, pathError: () => pathError)));
      }
    });
    on<DeleteProfile>((event, emit) {
      ProfilesState newState = state.copyWith(
          profiles: () => List.of(state.profiles)..remove(event.profile));
      if (newState.tabIndex == newState.profiles.length &&
          newState.tabIndex != 0) {
        newState = newState.copyWith(tabIndex: () => newState.tabIndex - 1);
      }
      emit(newState);
      _settingsRepository.profiles =
          state.profiles.map<String>((profile) => profile.toJson()).toList();
    });
  }

  String? _validateHKPath(String? path, int version) {
    if (path == null || path.isEmpty) {
      return 'Path can\'t be empty';
    }
    if (!Directory(path).existsSync()) {
      return 'Provided directory doesn\'t exist';
    }
    if (state.profiles
        .where((Profile profile) => profile.hkPath == path)
        .isNotEmpty) {
      return 'A profile at this path already exists';
    }
    switch (version) {
      case -1:
        {
          return 'Something went terribly wrong';
        }
      case 14:
        {
          if (!File(join(path, 'hollow_knight.exe')).existsSync() ||
              !Directory(join(path, 'hollow_knight_Data')).existsSync()) {
            return 'Provided directory is not a valid Hollow Knight 1.4 directory';
          }
          break;
        }
      case 15:
        {
          if (!File(join(path, 'Hollow Knight.exe')).existsSync() ||
              !Directory(join(path, 'Hollow Knight_Data')).existsSync()) {
            return 'Provided directory is not a valid Hollow Knight 1.5 directory';
          }
          break;
        }
    }
    return null;
  }

  String? _validateProfileName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Profile name cant be empty';
    }
    if (state.profiles
        .where((Profile profile) => profile.name == name)
        .isNotEmpty) {
      return 'A profile with this name already exists';
    }
    return null;
  }
}
