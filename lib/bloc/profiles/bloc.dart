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
                .toList())) {
    on<ChangeTab>(
        (event, emit) => emit(state.copyWith(tabIndex: () => event.index)));
    on<AddTab>(
        (event, emit) => emit(state.copyWith(newProfile: () => Profile())));
    on<PickHKFolder>((event, emit) async {
      String? path = await FilePicker.platform.getDirectoryPath();

      if (path != null) {
        emit(state.copyWith(
            newProfile: () => state.newProfile?.copyWith(hkPath: () => path)));
      }
    });
    on<CloseNewTabDialog>(
        (event, emit) => state.copyWith(newProfile: () => null));
    on<SubmitNewTabDialog>((event, emit) {
      String? nameError = _validateProfileName(event.name);
      String? pathError = _validateHKPath(event.path);

      if (nameError == null && pathError == null) {
        Profile newProfile = Profile(name: event.name, hkPath: event.path);
        emit(state.copyWith(
            newProfile: () => null,
            profiles: () => List.of(state.profiles)..add(newProfile)));

        _settingsRepository.profiles =
            state.profiles.map<String>((profile) => profile.toJson()).toList();
      } else {
        emit(state.copyWith(
            newProfile: () => state.newProfile?.copyWith(
                nameError: () => nameError, pathError: () => pathError)));
      }
    });
  }

  String? _validateHKPath(String? path) {
    if (path == null || path.isEmpty) {
      return 'Path can\'t be empty';
    }
    if (!Directory(path).existsSync()) {
      return 'Provided directory doesn\'t exist';
    }
    if (!((File(join(path, 'Hollow Knight.exe')).existsSync() &&
            Directory(join(path, 'Hollow Knight_Data')).existsSync()) ||
        (File(join(path, 'hollow_knight.exe')).existsSync() &&
            Directory(join(path, 'hollow_knight_Data')).existsSync()))) {
      return 'Provided directory is not a valid Hollow Knight directory';
    }
    return null;
  }

  String? _validateProfileName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Profile name cant be empty';
    }
    return null;
  }
}
