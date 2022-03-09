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
                      modpacks: () => _loadProfileModpacks(profileDir));
                }

                return const Profile(profileError: 'Profile not found!');
              }

              return const Profile(profileError: 'This profile is corrupted!');
            }).toList(),
            currentProfile: _settingsRepository.currentProfile)) {
    on<ChangeTab>(
        (event, emit) => emit(state.copyWith(tabIndex: () => event.index)));
    on<AddTab>((event, emit) =>
        emit(state.copyWith(newProfile: () => const Profile())));
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

      final String? nameError = await _validateProfileName(name),
          pathError = await _validateHKPath(rootPath, version ?? -1);

      if (nameError == null && pathError == null) {
        emit(state.copyWith(isNewProfileInitializing: () => true));

        try {
          final Directory vanillaModpackDir = Directory(
              join(hkModpacksPath(state.newProfile!.hkPath!), 'Vanilla'));

          await vanillaModpackDir.create(recursive: true);
          await Directory(hkManagedPath(rootPath!, version!)).move(
              hkModpackManagedPath(rootPath, 'Vanilla'),
              deleteSource: true);

          final Profile newProfile = Profile(
              name: name,
              hkPath: rootPath,
              hkVersion: version,
              modpacks: const <Modpack>[Modpack(name: 'Vanilla')]);

          if (state.profiles.isEmpty) {
            await _selectProfile(newProfile);
          }

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
              newProfile: () => state.newProfile?.copyWith(
                  profileError: () =>
                      exception.osError?.message ?? 'Unknown error')));
        }
      } else {
        emit(state.copyWith(
            newProfile: () => state.newProfile?.copyWith(
                nameError: () => nameError, pathError: () => pathError)));
      }
    });
    on<DeleteProfile>((event, emit) async {
      emit(state.copyWith(isDeletingProfile: () => true));

      ProfilesState newState = state.copyWith(
          profiles: () => List.of(state.profiles)
            ..removeWhere((profile) => profile.name == event.profile.name),
          isDeletingProfile: () => false);

      if (newState.tabIndex == newState.profiles.length &&
          newState.tabIndex != 0) {
        newState = newState.copyWith(tabIndex: () => newState.tabIndex - 1);
      }

      if (state.currentProfile == event.profile.name) {
        newState = newState.copyWith(currentProfile: () => null);

        _settingsRepository.currentProfile = null;
      }

      await deleteProfile(event.profile);

      emit(newState);

      _settingsRepository.profiles =
          state.profiles.map<String>((profile) => profile.toJson()).toList();
    });
    on<MakeProfileCurrent>((event, emit) async {
      emit(state.copyWith(currentProfile: () => event.profile.name));

      await _selectProfile(event.profile);

      _settingsRepository.currentProfile = event.profile.name;
    });
    on<SelectModpack>((event, emit) async {
      if (event.profile.selectedModpack != event.modpack.name) {
        if ((await Directory(hkSavesPath()).exists() &&
                !await Link(hkSavesPath()).exists()) ||
            (await Directory(hkManagedPath(
                        event.profile.hkPath!, event.profile.hkVersion))
                    .exists() &&
                !await Link(hkManagedPath(
                        event.profile.hkPath!, event.profile.hkVersion))
                    .exists())) {
          emit(state.copyWith(
              modpackLoadError: () =>
                  'It seems like a part of your HK installation hasn\'t been converted for use with this launcher. Please verify that your installation and save files are not corrupted, delete this profile and create it again.'));
        } else {
          try {
            final Profile profile = event.profile
                .copyWith(selectedModpack: () => event.modpack.name!);

            await _selectProfile(profile);

            emit(state.copyWith(
                profiles: () => List.of(state.profiles)
                  ..[state.profiles.indexOf(event.profile)] = profile));
          } on FileSystemException catch (exception) {
            emit(state.copyWith(
                modpackLoadError: () =>
                    exception.osError?.message ?? 'Unknown error'));
          }
        }
      }
    });
    on<CloseModpackErrorDialog>(
        (event, emit) => emit(state.copyWith(modpackLoadError: () => null)));
    on<DuplicateModpack>((event, emit) => emit(state.copyWith(
        newModpack: () => Modpack(basedOn: event.modpack.name))));
    on<ShowModpackInExplorer>((event, emit) =>
        Directory(hkModpackPath(event.profile.hkPath!, event.modpack.name!))
            .showInExplorer());
    on<SubmitNewModpackDialog>((event, emit) async {
      final String? modpackError = await _validateModpack(
          event.profile.hkPath!, event.modpack.name?.trim());

      if (modpackError == null) {
        emit(state.copyWith(isNewModpackInitializing: () => true));

        await _createModpack(event.profile, event.modpack);

        emit(state.copyWith(
            newModpack: () => null,
            isNewModpackInitializing: () => false,
            profiles: () => List.of(state.profiles)
              ..[state.profiles.indexOf(event.profile)] = event.profile
                  .copyWith(
                      modpacks: () => _loadProfileModpacks(
                          Directory(hkModpacksPath(event.profile.hkPath!))))));
      } else {
        emit(state.copyWith(
            newModpack: () =>
                state.newModpack?.copyWith(nameError: () => modpackError)));
      }
    });
    on<ChangeNewModpackName>((event, emit) => emit(state.copyWith(
        newModpack: () => state.newModpack?.copyWith(name: () => event.name))));
    on<CloseNewModpackDialog>(
        (event, emit) => emit(state.copyWith(newModpack: () => null)));
    on<LaunchHK>(((event, emit) {
      Profile currentProfile = state.profiles
          .singleWhere((profile) => profile.name == state.currentProfile);

      launchHK(currentProfile.hkPath!, currentProfile.hkVersion);
    }));
  }

  Future<String?> _validateHKPath(String? path, int version) async {
    if (path == null || path.isEmpty) {
      return 'Path can\'t be empty';
    }
    if (!await Directory(path).exists()) {
      return 'Provided directory doesn\'t exist';
    }
    if (state.profiles
        .where((Profile profile) => profile.hkPath == path)
        .isNotEmpty) {
      return 'A profile at this path already exists';
    }
    if (!await File(hkExePath(path, version)).exists() ||
        !await Directory(hkDataPath(path, version)).exists()) {
      return 'Provided directory is not a valid Hollow Knight directory for selected version';
    }
    return null;
  }

  Future<String?> _validateProfileName(String? name) async {
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

  static Future<String?> _validateModpack(String rootPath, String? name) async {
    if (name == null || name.isEmpty) {
      return 'Modpack name cant be empty';
    }
    if (name.split('').any((char) =>
        const ['<', '>', ':', '"', '/', '\\', '|', '?', '*'].contains(char))) {
      return r'Sorry but the following characters are not allowed: <>:"/\|?*';
    }
    if (await Directory(hkModpackPath(rootPath, name)).exists()) {
      return 'A modpack at this path already exists';
    }
    return null;
  }

  static Future<void> _createModpack(Profile profile, Modpack modpack) async {
    String name = modpack.name!.trim();

    final Directory modpackDir =
        Directory(hkModpackPath(profile.hkPath!, name));

    if (await modpackDir.exists()) {
      await modpackDir.delete();
    }

    final Directory basedOnModpackManagedDir =
        Directory(hkModpackManagedPath(profile.hkPath!, modpack.basedOn!));

    await basedOnModpackManagedDir
        .move(hkModpackManagedPath(profile.hkPath!, name));

    await Directory(hkModpackSavesPath(profile.hkPath!, name)).create();
  }

  static Future<void> _selectProfile(Profile profile) async {
    final Directory modpackSavesDir = Directory(
            hkModpackSavesPath(profile.hkPath!, profile.selectedModpack)),
        savesDir = Directory(hkSavesPath());

    if (await savesDir.exists()) {
      await savesDir.rename('Hollow Knight (← your old saves are here)');
    }

    if (!await modpackSavesDir.exists()) {
      await modpackSavesDir.create();
    }

    await Link(hkSavesPath())
        .set(hkModpackSavesPath(profile.hkPath!, profile.selectedModpack));
    await Link(hkManagedPath(profile.hkPath!, profile.hkVersion))
        .set(hkModpackManagedPath(profile.hkPath!, profile.selectedModpack));
  }

  static List<Modpack> _loadProfileModpacks(Directory profileDir) => (profileDir
          .listSync()
        ..sort((element1, element2) =>
            element1.statSync().changed.compareTo(element2.statSync().changed)))
      .whereType<Directory>()
      .map<Modpack>((element) => Modpack(name: basename(element.path)))
      .toList();

  static Future<void> deleteProfile(Profile profile) async {
    Link managedLnk = Link(hkManagedPath(profile.hkPath!, profile.hkVersion)),
        savesLnk = Link(hkSavesPath());

    if (await managedLnk.exists()) {
      await managedLnk.delete();
    }

    if (await savesLnk.exists()) {
      await savesLnk.delete();
    }

    await Directory(hkModpackManagedPath(profile.hkPath!, 'Vanilla'))
        .move(hkManagedPath(profile.hkPath!, profile.hkVersion));

    await Directory(hkModpacksPath(profile.hkPath!)).delete(recursive: true);
  }
}
