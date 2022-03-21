import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../util/extensions.dart';
import '../../util/hollow_knight.dart';

import '../../data/settings/settings_repository.dart';
import 'events.dart';
import 'state.dart';

class LoadingBloc extends Bloc<LoadingEvent, LoadingState> {
  final SettingsRepository _settingsRepository;

  LoadingBloc(this._settingsRepository)
      : super(const LoadingState(false, false)) {
    Future.wait(<Future>[
      _settingsRepository.init(),
      _delayStart(),
    ]).then((value) => add(LoadingFinished()));

    on<LoadingFinished>((event, emit) {
      if (_settingsRepository.seenDisclaimer) {
        emit(const LoadingState(true, false));
      } else {
        emit(const LoadingState(false, true));
      }
    });
    on<DismissedDisclaimer>((event, emit) {
      _settingsRepository.seenDisclaimer = true;

      emit(const LoadingState(true, false));
    });
    on<OpenSavesFolder>(
        (event, emit) async => Directory(hkSavesPath()).selectInExplorer());
  }

  Future _delayStart() => Future.delayed(const Duration(seconds: 1));
}
