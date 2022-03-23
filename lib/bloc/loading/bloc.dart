import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hk_launcher/util/translations.dart';
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
      _loadTranslations(),
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

  Future<void> _loadTranslations() async {
    Map<String, dynamic> i18n =
        jsonDecode(await rootBundle.loadString('assets/translations.json'));

    locales = (i18n['locales'] as Map<String, dynamic>).cast<String, String>();
    translations = i18n['translations'];

    currentLocale = _settingsRepository.locale;
  }

  Future _delayStart() => Future.delayed(const Duration(seconds: 1));
}
