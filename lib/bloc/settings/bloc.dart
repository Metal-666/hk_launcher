import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hk_launcher/data/settings/settings_repository.dart';
import 'package:quiver/collection.dart';

import '../../util/converters.dart';
import 'events.dart';
import 'state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc(this._settingsRepository)
      : super(SettingsState(
            false,
            themeModeConverter[_settingsRepository.themeMode] ??
                ThemeMode.system)) {
    on<ThemeModeChanged>(((event, emit) {
      _settingsRepository.themeMode =
          themeModeConverter.inverse[event.themeMode];
      emit(state.copyWith(needsRestart: () => true));
    }));
  }
}
