import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/settings/settings_repository.dart';
import 'events.dart';
import 'states.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final SettingsRepository _settingsRepository;

  MainBloc(this._settingsRepository) : super(MainState(0, true)) {
    on<Navigate>(
        (event, emit) => emit(state.copyWith(navIndex: () => event.index)));
    on<AppLoaded>((event, emit) => {
          emit(state.copyWith(
              hkPathPresent: () => _settingsRepository.hkPath != null))
        });
  }
}
