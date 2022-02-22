import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';

import '../../data/settings/settings_repository.dart';
import 'events.dart';
import 'state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final SettingsRepository _settingsRepository;

  MainBloc(this._settingsRepository) : super(MainState(0, null)) {
    on<Navigate>(
        (event, emit) => emit(state.copyWith(navIndex: () => event.index)));
    on<AppLoaded>((event, emit) => {
          emit(state.copyWith(
              hkPathDialog: () => _validateHKPath(_settingsRepository.hkPath)
                  ? null
                  : HKPathDialog(null, null)))
        });
    on<PickHKFolder>((event, emit) async {
      String? path = await FilePicker.platform.getDirectoryPath();

      if (path != null) {
        emit(state.copyWith(hkPathDialog: () => HKPathDialog(path, null)));
      }
    });
    on<HKPathDialogDismissed>((event, emit) => exit(0));
    on<HKPathProvided>((event, emit) {
      String path = event.path;
      if (_validateHKPath(path)) {
        _settingsRepository.hkPath = path;
        emit(state.copyWith(hkPathDialog: () => null));
      } else {
        emit(state.copyWith(
            hkPathDialog: () => HKPathDialog(path,
                'Selected directory doesn\'t exist or is not a valid Hollow Knight directory')));
      }
    });
  }

  bool _validateHKPath(String? path) =>
      path == null &&
      Directory(path!).existsSync() &&
      File(join(path, 'Hollow Knight.exe')).existsSync() &&
      Directory(join(path, 'Hollow Knight_Data')).existsSync();
}
