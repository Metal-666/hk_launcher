import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/settings/settings_repository.dart';

import '../../util/converters.dart';
import '../profiles/bloc.dart';
import '../profiles/state.dart';
import 'events.dart';
import 'state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc(this._settingsRepository)
      : super(SettingsState(
            themeMode: themeModeConverter[_settingsRepository.themeMode] ??
                ThemeMode.system)) {
    on<ThemeModeChanged>(((event, emit) {
      _settingsRepository.themeMode =
          themeModeConverter.inverse[event.themeMode];
      emit(state.copyWith(needsRestart: () => true));
    }));
    on<RestoreHK>((event, emit) async {
      emit(state.copyWith(restoringHK: () => true));

      _settingsRepository.currentProfile = null;

      for (final profileJson in _settingsRepository.profiles) {
        await ProfilesBloc.deleteProfile(Profile.fromJson(profileJson));
      }

      _settingsRepository.profiles = null;

      emit(state.copyWith(
        restoringHK: () => false,
        needsRestart: () => true,
      ));
    });
  }
}
