import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/settings/settings_repository.dart';
import 'events.dart';
import 'state.dart';

class LoadingBloc extends Bloc<LoadingEvent, LoadingState> {
  final SettingsRepository _settingsRepository;

  LoadingBloc(this._settingsRepository) : super(LoadingState(false)) {
    Future.wait(<Future>[_settingsRepository.init(), _delayStart()])
        .then((value) => add(LoadingFinished()));

    on<LoadingFinished>((event, emit) => emit(LoadingState(true)));
  }

  Future _delayStart() => Future.delayed(const Duration(seconds: 5));
}
