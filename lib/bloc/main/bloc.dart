import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/settings/settings_repository.dart';
import 'events.dart';
import 'state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final SettingsRepository _settingsRepository;

  MainBloc(this._settingsRepository) : super(const MainState(0)) {
    on<Navigate>(
        (event, emit) => emit(state.copyWith(navIndex: () => event.index)));
    on<AppLoaded>((event, emit) => {
          // Called when this bloc is constructed. Normally I would do some initializtion here, but it is already done in loading bloc. I might use this for something in the future, so I will leave the handler.
        });
    on<OpenGitHub>((event, emit) async =>
        await launch('https://github.com/Metal-666/hk_launcher'));
  }
}
