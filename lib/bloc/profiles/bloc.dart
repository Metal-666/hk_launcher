import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hk_launcher/util/extensions.dart';
import 'package:path/path.dart';

import '../../data/settings/settings_repository.dart';
import '../../util/hollow_knight.dart';
import 'events.dart';
import 'state.dart';

class ProfilesBloc extends Bloc<ProfilesEvent, ProfilesState> {
  final SettingsRepository _settingsRepository;

  ProfilesBloc(this._settingsRepository)
      : super(ProfilesState(
            0,
            _settingsRepository.profiles.map<Profile>((profileJson) {
              final Profile profile = Profile.fromJson(profileJson);

              if (profile.hkPath != null || profile.name != null) {
                final Directory profileDir =
                    Directory(hkModpacksPath(profile.hkPath!));

                if (profileDir.existsSync()) {
                  return profile.copyWith(
                      modpacks: () => profileDir
                              .listSync()
                              .whereType<Directory>()
                              .map<Modpack>((element) {
                            var modpack = Modpack(basename(element.path));
                            return modpack;
                          }).toList());
                }

                return const Profile(profileError: 'Profile not found!');
              }

              return const Profile(profileError: 'This profile is corrupted!');
            }).toList(),
            currentProfile: _settingsRepository.currentProfile)) {
    on<ChangeTab>(
        (event, emit) => emit(state.copyWith(tabIndex: () => event.index)));
    on<AddTab>((event, emit) => emit(state.copyWith(
        newProfile: () => const Profile(), newProfileError: () => null)));
    on<PickHKFolder>((event, emit) async {
      final String? path =
          await FilePicker.platform.getDirectoryPath(lockParentWindow: true);

      if (path != null) {
        emit(state.copyWith(
            newProfile: () => state.newProfile?.copyWith(
                hkPath: () => path, shouldOverwritePath: () => true)));
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
      final String? rootPath = state.newProfile?.hkPath,
          name = state.newProfile?.name;
      final int? version = state.newProfile?.hkVersion;

      final String? nameError = _validateProfileName(name);
      final String? pathError = _validateHKPath(rootPath, version ?? -1);

      if (nameError == null && pathError == null) {
        emit(state.copyWith(isNewProfileInitializing: () => true));

        try {
          final Directory vanillaModpackDir = Directory(
              join(hkModpacksPath(state.newProfile!.hkPath!), 'Vanilla'));

          await vanillaModpackDir.create(recursive: true);
          await Directory(hkManagedPath(rootPath!, version!))
              .move(hkModpackManagedPath(rootPath, 'Vanilla'));
          await Directory(hkSavesPath())
              .move(hkModpackSavesPath(rootPath, 'Vanilla'));
          await Link(hkManagedPath(rootPath, version))
              .create(hkModpackManagedPath(rootPath, 'Vanilla'));
          await Link(hkSavesPath())
              .create(hkModpackSavesPath(rootPath, 'Vanilla'));

          final Profile newProfile =
              Profile(name: name, hkPath: rootPath, hkVersion: version);

          emit(state.copyWith(
              newProfile: () => null,
              isNewProfileInitializing: () => false,
              profiles: () => List.of(state.profiles)..add(newProfile)));

          _settingsRepository.profiles = state.profiles
              .map<String>((profile) => profile.toJson())
              .toList();
        } on FileSystemException catch (exception) {
          emit(state.copyWith(
              isNewProfileInitializing: () => false,
              newProfileError: () =>
                  exception.osError?.message ?? 'Unknown error'));
        }
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
    on<MakeProfileCurrent>((event, emit) {
      emit(state.copyWith(currentProfile: () => event.profile.name));

      _settingsRepository.currentProfile = event.profile.name;
    });
    on<SelectModpack>((event, emit) {
      if (event.profile.selectedModpack != event.modpack.name) {
        //
        //apply modpack
        //

        emit(state.copyWith(
            profiles: () => List.of(state.profiles)
              ..[state.profiles.indexOf(event.profile)] = event.profile
                  .copyWith(selectedModpack: () => event.modpack.name)));
      }
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
    if (!File(hkExePath(path, version)).existsSync() ||
        !Directory(hkDataPath(path, version)).existsSync()) {
      return 'Provided directory is not a valid Hollow Knight directory for selected version';
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
