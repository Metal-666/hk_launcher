import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../util/extensions.dart';
import '../../util/hollow_knight.dart';

import 'events.dart';
import 'state.dart';

import 'package:path/path.dart';

class SavesBloc extends Bloc<SavesEvent, SavesState> {
  SavesBloc() : super(const SavesState()) {
    on<OpenLocationInExplorer>(
        (event, emit) => Directory(hkSavesPath()).selectInExplorer());
    on<CopyLocationToClipboard>(
        (event, emit) => Clipboard.setData(ClipboardData(text: hkSavesPath())));
    on<Backup>((event, emit) async {
      final Directory savesDir = Directory(hkSavesPath());

      if (await savesDir.exists()) {
        emit(state.copyWith(backupCooldown: () => true));

        final DateTime dateTime = DateTime.now();

        (await savesDir.move(join(
          savesDir.parent.path,
          'Backups',
          (StringBuffer()
                ..writeAll(
                  <int>[
                    dateTime.year,
                    dateTime.month,
                    dateTime.day,
                  ].map(
                    (value) => value.toString().padLeft(2, '0'),
                  ),
                  '-',
                )
                ..write(' ')
                ..writeAll(
                  <int>[
                    dateTime.hour,
                    dateTime.minute,
                    dateTime.second,
                  ].map(
                    (value) => value.toString().padLeft(2, '0'),
                  ),
                  '.',
                ))
              .toString(),
        )))
            .showInExplorer();

        emit(state.copyWith(backupCooldown: () => false));
      }
    });
  }
}
